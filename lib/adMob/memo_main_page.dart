import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class MemoMainPage extends StatefulWidget {
  const MemoMainPage({super.key});

  @override
  State<MemoMainPage> createState() => _MemoMainPageState();
}

class _MemoMainPageState extends State<MemoMainPage> {
  BannerAd? _bannerAd;
  final String _adUnitId = 'ca-app-pub-3940256099942544/6300978111'; // 구글 테스트 ID

  @override
  void initState() {
    super.initState();
    
    // [핵심 수정] 광고 SDK를 이 페이지가 시작될 때 초기화합니다.
    // 이렇게 하면 main()에서 Workmanager와의 충돌을 피할 수 있습니다.
    MobileAds.instance.initialize();

    _loadAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('광고 제거'),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // 페이지의 주요 내용 (현재는 비어있음)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  '광고 제거 옵션은 현재 준비 중입니다.\n광고 시청으로 앱 개발을 응원해주세요!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            
            // 배너 광고를 화면 하단에 표시
            if (_bannerAd != null)
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  child: SizedBox(
                    width: _bannerAd!.size.width.toDouble(),
                    height: _bannerAd!.size.height.toDouble(),
                    child: AdWidget(ad: _bannerAd!),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  /// 광고를 로드하는 메소드
  void _loadAd() {
    final bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: _adUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        // 광고가 성공적으로 로드되면
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        // 광고 로드에 실패하면
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('광고 로드 실패: ${error.message}');
        },
      ),
    );

    // 광고 로드 시작
    bannerAd.load();
  }
}