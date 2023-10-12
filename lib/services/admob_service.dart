import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService extends ChangeNotifier {
  // Regra Para Exibir Na Tela de Agendamento
  bool madeAnAppointment = false;

  getMadeAnAppointment() {
    return madeAnAppointment;
  }

  updateMadeAnAppointment() {
    madeAnAppointment = !madeAnAppointment;
    notifyListeners();
  }

  int showAdsScreenSchedule = 0;
  int isToDisplay = 0;

  getIsToDisplay() {
    return isToDisplay;
  }

  updateisToDisplay() {
    isToDisplay++;
    notifyListeners();
  }

  getShowAdsScreenSchedule() {
    return showAdsScreenSchedule;
  }

  updateShowAdsScreenSchedule() {
    showAdsScreenSchedule = showAdsScreenSchedule + 1;
    notifyListeners();
  }

  // Regra Para Exibir Na Opção de Selecionar Dias Para o Agendamento

  int showAdsScreenHome = 1;
  int isToDisplayHome = 0;

  getIsToDisplayHome() {
    return isToDisplayHome;
  }

  updateisToDisplayHome() {
    isToDisplayHome++;
    notifyListeners();
  }

  getShowAdsScreenHome() {
    return showAdsScreenHome;
  }

  updateShowAdsScreenHome() {
    showAdsScreenHome = showAdsScreenHome + 3;
    notifyListeners();
  }

  // Funções para rodar ADS
  static Future<String?> get bannerAdUnitId async {
    final idBanner = await FirebaseFirestore.instance
        .collection('ads')
        .doc('GJFxug1viNysytnrdqwG')
        .get();

    if (Platform.isAndroid) {
      return idBanner['bannerInitialScreen'];
    } else if (Platform.isIOS) {
      return idBanner['bannerInitialScreen'];
    }
  }

  interstitialAdId() async {
    final idInterstitial = await FirebaseFirestore.instance
        .collection('ads')
        .doc('GJFxug1viNysytnrdqwG')
        .get();

    String? adsId =
        Platform.isAndroid ? idInterstitial['interstitialAndroid'] : null;

    InterstitialAd.load(
      adUnitId: adsId!,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.show();
        },
        onAdFailedToLoad: (error) {},
      ),
    );
  }
}
