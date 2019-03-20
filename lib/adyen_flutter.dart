import 'dart:async';
import 'package:meta/meta.dart';

import 'package:flutter/services.dart';

class AdyenFlutter {
  static const MethodChannel _channel = const MethodChannel('adyen_flutter');

  /// Encrypts Card information after requesting public key from token into a single string token
  static Future<String> encryptedToken(
      {@required String publicKeyToken,
      Environment environment = Environment.TEST,
      String holderName,
      @required CreditCard card,
      @required DateTime generationDate}) async {
    ArgumentError.checkNotNull(publicKeyToken, 'publicKeyToken');
    ArgumentError.checkNotNull(generationDate, 'generationDate');
    ArgumentError.checkNotNull(card, 'card');
    ArgumentError.checkNotNull(card.number, 'card.number');
    ArgumentError.checkNotNull(card.securityCode, 'card.securityCode');
    ArgumentError.checkNotNull(card.expiryMonth, 'card.expiryMonth');
    ArgumentError.checkNotNull(card.expiryYear, 'card.expiryYear');

    try {
      return await _channel.invokeMethod('encryptedToken', <String, dynamic>{
        'publicKeyToken': publicKeyToken,
        'cardNumber': card.number,
        'cardSecurityCode': card.securityCode,
        'cardExpiryMonth': card.expiryMonth,
        'cardExpiryYear': card.expiryYear,
        'environment': environment.toString().split('.')[1],
        'holderName': holderName,
        'generationDate': generationDate.toIso8601String()
      });
    } catch (ex) {
      throw Exception('Could not encrypt the token from the card:$ex');
    }
  }

  /// Encrypts Card information after requesting public key from token into a card with encrypted values
  static Future<CreditCard> encryptedCard(
      {@required String publicKeyToken,
      Environment environment = Environment.TEST,
      @required CreditCard card,
      @required DateTime generationDate}) async {
    ArgumentError.checkNotNull(publicKeyToken, 'publicKeyToken');
    ArgumentError.checkNotNull(generationDate, 'generationDate');
    ArgumentError.checkNotNull(card, 'card');
    ArgumentError.checkNotNull(card.number, 'card.number');
    ArgumentError.checkNotNull(card.securityCode, 'card.securityCode');
    ArgumentError.checkNotNull(card.expiryMonth, 'card.expiryMonth');
    ArgumentError.checkNotNull(card.expiryYear, 'card.expiryYear');
    try {
      final Map<dynamic, dynamic> results =
          await _channel.invokeMethod('encryptedCard', <String, dynamic>{
        'publicKeyToken': publicKeyToken,
        'cardNumber': card.number,
        'cardSecurityCode': card.securityCode,
        'cardExpiryMonth': card.expiryMonth,
        'cardExpiryYear': card.expiryYear,
        'environment': environment.toString().split('.')[1],
        'generationDate': generationDate.toIso8601String()
      });
      var encryptedNumber = results['encryptedNumber'];
      var encryptedSecurityCode = results['encryptedSecurityCode'];
      var encryptedExpiryMonth = results['encryptedExpiryMonth'];
      var encryptedExpiryYear = results['encryptedExpiryYear'];
      return CreditCard(
          number: encryptedNumber,
          securityCode: encryptedSecurityCode,
          expiryMonth: encryptedExpiryMonth,
          expiryYear: encryptedExpiryYear);
    } catch (ex) {
      throw new Exception("Could not encrypt the card:$ex");
    }
  }
}

enum Environment { TEST, LIVE }

class CreditCard {
  ///The card Number
  final String number;

  ///The card security code
  final String securityCode;

  ///The card expiry Month.
  ///Valid Value are [1-12]
  final String expiryMonth;

  ///The card expiry year.
  final String expiryYear;

  CreditCard(
      {@required this.number,
      @required this.securityCode,
      @required this.expiryMonth,
      @required this.expiryYear});
}