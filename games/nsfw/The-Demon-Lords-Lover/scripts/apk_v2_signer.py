import struct, hashlib, os
from cryptography.hazmat.primitives.asymmetric import rsa, padding
from cryptography.hazmat.primitives import hashes, serialization
from cryptography import x509
from cryptography.x509.oid import NameOID
import datetime

def generate_key_and_cert():
    key = rsa.generate_private_key(public_exponent=65537, key_size=2048)
    subject = issuer = x509.Name([
        x509.NameAttribute(NameOID.COMMON_NAME, "DemonLordsLoverPTBR"),
        x509.NameAttribute(NameOID.ORGANIZATION_NAME, "TranslationTeam")
    ])
    cert = x509.CertificateBuilder().subject_name(
        subject
    ).issuer_name(
        issuer
    ).public_key(
        key.public_key()
    ).serial_number(
        x509.random_serial_number()
    ).not_valid_before(
        datetime.datetime.now(datetime.timezone.utc) - datetime.timedelta(days=1)
    ).not_valid_after(
        datetime.datetime.now(datetime.timezone.utc) + datetime.timedelta(days=3650)
    ).sign(key, hashes.SHA256())
    
    cert_der = cert.public_bytes(serialization.Encoding.DER)
    pubkey_der = key.public_key().public_bytes(
        serialization.Encoding.DER,
        serialization.PublicFormat.SubjectPublicKeyInfo
    )
    return key, cert_der, pubkey_der

def compute_v2_digest(apk_bytes, cd_offset, eocd_offset):
    # Section 1: 0 to cd_offset
    # Section 2: Central Directory (cd_offset to eocd_offset)
    # Section 3: EOCD with CD offset modified to cd_offset
    sec1 = apk_bytes[:cd_offset]
    sec2 = apk_bytes[cd_offset:eocd_offset]
    
    # EOCD is 22 bytes + comment length
    eocd = bytearray(apk_bytes[eocd_offset:])
    # set CD offset in EOCD (offset 16-20) to cd_offset
    struct.pack_into('<I', eocd, 16, cd_offset)
    
    sections = [sec1, sec2, bytes(eocd)]
    
    chunk_hashes = []
    CHUNK_SIZE = 1048576 # 1 MB
    
    for sec in sections:
        num_chunks = (len(sec) + CHUNK_SIZE - 1) // CHUNK_SIZE
        if num_chunks == 0 and len(sec) == 0:
            continue
        for i in range(num_chunks):
            chunk = sec[i * CHUNK_SIZE : (i + 1) * CHUNK_SIZE]
            prefix = b'\xa5' + struct.pack('<I', len(chunk))
            chunk_hashes.append(hashlib.sha256(prefix + chunk).digest())
            
    # Top level digest
    top_prefix = b'\x5a' + struct.pack('<I', len(chunk_hashes))
    top_digest = hashlib.sha256(top_prefix + b''.join(chunk_hashes)).digest()
    return top_digest

def sign_apk_v2(input_apk_path, output_apk_path):
    with open(input_apk_path, 'rb') as f:
        apk_data = f.read()
        
    eocd_idx = apk_data.rfind(b'\x50\x4b\x05\x06')
    if eocd_idx == -1:
        raise ValueError("Not a valid ZIP file (EOCD not found)")
        
    cd_offset = struct.unpack('<I', apk_data[eocd_idx+16:eocd_idx+20])[0]
    
    # Check if there is an existing APK signing block before cd_offset
    if cd_offset >= 16 and apk_data[cd_offset-16:cd_offset] == b'APK Sig Block 42':
        block_size = struct.unpack('<Q', apk_data[cd_offset-24:cd_offset-16])[0]
        entries_end = cd_offset - block_size - 8
        print(f"Stripping existing APK Signing Block of size {block_size}")
        clean_apk = apk_data[:entries_end] + apk_data[cd_offset:]
        new_cd_offset = entries_end
        new_eocd_idx = len(clean_apk) - (len(apk_data) - eocd_idx)
        eocd_bytes = bytearray(clean_apk[new_eocd_idx:])
        struct.pack_into('<I', eocd_bytes, 16, new_cd_offset)
        clean_apk = clean_apk[:new_eocd_idx] + bytes(eocd_bytes)
        apk_data = clean_apk
        cd_offset = new_cd_offset
        eocd_idx = new_eocd_idx
        
    key, cert_der, pubkey_der = generate_key_and_cert()
    top_digest = compute_v2_digest(apk_data, cd_offset, eocd_idx)
    
    # Build SignedData:
    digest_entry = struct.pack('<I', 0x0103) + struct.pack('<I', len(top_digest)) + top_digest
    digests_block = struct.pack('<I', len(digest_entry)) + digest_entry
    digests_field = struct.pack('<I', len(digests_block)) + digests_block
    
    cert_entry = struct.pack('<I', len(cert_der)) + cert_der
    certs_block = struct.pack('<I', len(cert_entry)) + cert_entry
    certs_field = struct.pack('<I', len(certs_block)) + certs_block
    
    attrs_field = struct.pack('<I', 0)
    signed_data = digests_field + certs_field + attrs_field
    
    signature = key.sign(
        signed_data,
        padding.PKCS1v15(),
        hashes.SHA256()
    )
    
    sig_entry = struct.pack('<I', 0x0103) + struct.pack('<I', len(signature)) + signature
    sigs_block = struct.pack('<I', len(sig_entry)) + sig_entry
    sigs_field = struct.pack('<I', len(sigs_block)) + sigs_block
    
    pubkey_field = struct.pack('<I', len(pubkey_der)) + pubkey_der
    
    signer = struct.pack('<I', len(signed_data)) + signed_data + sigs_field + pubkey_field
    signers_block = struct.pack('<I', len(signer)) + signer
    signers_field = struct.pack('<I', len(signers_block)) + signers_block
    
    v2_id = 0x7109871a
    pair_len = 4 + len(signers_field)
    pair = struct.pack('<Q', pair_len) + struct.pack('<I', v2_id) + signers_field
    
    # Block size = len(pair) + 24
    block_size = len(pair) + 24
    magic = b'APK Sig Block 42'
    signing_block = (
        struct.pack('<Q', block_size) +
        pair +
        struct.pack('<Q', block_size) +
        magic
    )
    
    entries = apk_data[:cd_offset]
    cd = apk_data[cd_offset:eocd_idx]
    
    new_cd_offset = cd_offset + len(signing_block)
    eocd_new = bytearray(apk_data[eocd_idx:])
    struct.pack_into('<I', eocd_new, 16, new_cd_offset)
    
    with open(output_apk_path, 'wb') as out_f:
        out_f.write(entries)
        out_f.write(signing_block)
        out_f.write(cd)
        out_f.write(eocd_new)
        
    print(f"Successfully signed {output_apk_path} with APK Signature Scheme v2!")
    print(f"Signing block length: {len(signing_block)} bytes (block_size field: {block_size})")
