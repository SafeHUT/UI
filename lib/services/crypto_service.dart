import 'dart:convert';
import 'package:cryptography/cryptography.dart';

class CryptoService {

  static final X25519 _x25519 = X25519();
  static final AesGcm _aesGcm = AesGcm.with256bits();

  static Future<Map<String, String>> generateKeyPair() async {

    final keyPair = await _x25519.newKeyPair();
    final publicKey = await keyPair.extractPublicKey();
    final privateKeyBytes = await keyPair.extractPrivateKeyBytes();

    final publicKeyBase64 = base64Encode(publicKey.bytes);
    final privateKeyBase64 = base64Encode(privateKeyBytes);

    return {
      'publicKey': publicKeyBase64,
      'privateKey': privateKeyBase64,
    };
  }

  static Future<String> generateRoomKey() async {
    final secretKey = await _aesGcm.newSecretKey();
    final secretKeyBytes = await secretKey.extractBytes();
    return base64Encode(secretKeyBytes);
  }

  static Future<String> encryptMessage({
    required String plaintext,
    required String roomkeyBase64, 
  }) async {
    final secretKey = SecretKey(base64Decode(roomkeyBase64));
    final nonce = _aesGcm.newNonce();

    final secretBox = await _aesGcm.encrypt(
      utf8.encode(plaintext),
      secretKey: secretKey,
      nonce: nonce
    );

    final payload = {
      'nonce': base64Encode(secretBox.nonce),
      'ciphertext': base64Encode(secretBox.cipherText),
      'mac': base64Encode(secretBox.mac.bytes) 
    };
    return jsonEncode(payload);
  }

  static Future<String> decryptMessage({
    required String encryptedPayload,
    required String roomkeyBase64, 
  }) async {
    try {
      final Map<String,dynamic>  data = jsonDecode(encryptedPayload);
      final secretKey = SecretKey(base64Decode(roomkeyBase64));
      final secretBox = SecretBox(
        base64Decode(data['ciphertext'] as String),
        nonce: base64Decode(data['nonce'] as String),
        mac: Mac(base64Decode(data['mac'] as String)),
      );

      final clearTextBytes = await _aesGcm.decrypt(
        secretBox,
        secretKey: secretKey,
      );
      return utf8.decode(clearTextBytes);
    } catch(e) {
      return "Unable to decrypt message";
    }
  }

  static Future<String> wrapRoomKey({
    required String myPrivateKeyBase64,
    required String theirPublicKeyBase64,
    required String roomKeyBase64,
  }) async {
    final privateKeyBytes = base64Decode(myPrivateKeyBase64);
    final myKeyPair = await _x25519.newKeyPairFromSeed(privateKeyBytes);
    
    final theirPublicKey = SimplePublicKey(base64Decode(theirPublicKeyBase64), type: KeyPairType.x25519);

    final sharedSecret = await _x25519.sharedSecretKey(
      keyPair: myKeyPair,
      remotePublicKey: theirPublicKey,
    );
    final nonce = _aesGcm.newNonce();
    final secretBox = await _aesGcm.encrypt(
      base64Decode(roomKeyBase64),
      secretKey: sharedSecret,
      nonce: nonce,
    );

    return jsonEncode({
      'nonce': base64Encode(secretBox.nonce),
      'ciphertext': base64Encode(secretBox.cipherText),
      'mac': base64Encode(secretBox.mac.bytes),
    });
  }

  static Future<String> unwrapRoomKey({
    required String myPrivateKeyBase64,
    required String theirPublicKeyBase64,
    required String wrappedKeyPayload,
  }) async {
    
    final privateKeyBytes = base64Decode(myPrivateKeyBase64);
    final myKeyPair = await _x25519.newKeyPairFromSeed(privateKeyBytes);
    
    final theirPublicKey = SimplePublicKey(base64Decode(theirPublicKeyBase64), type: KeyPairType.x25519);

    final sharedSecret = await _x25519.sharedSecretKey(
      keyPair: myKeyPair,
      remotePublicKey: theirPublicKey,
    );

    final data = jsonDecode(wrappedKeyPayload);
    final secretBox = SecretBox(
      base64Decode(data['ciphertext']),
      nonce: base64Decode(data['nonce']),
      mac: Mac(base64Decode(data['mac'])),
    );

    final clearTextBytes = await _aesGcm.decrypt(
      secretBox,
      secretKey: sharedSecret,
    );

    return base64Encode(clearTextBytes);
  }
}