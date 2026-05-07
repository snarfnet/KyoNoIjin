# 提出前チェック

1. Xcodeで `C:\Users\Windows\KyoNoIjin\KyoNoIjin.xcodeproj` を開く
2. Package DependenciesでGoogle Mobile Ads 11.13.0が解決されているか確認
3. Signing & CapabilitiesでTeamを選ぶ
4. Bundle IdentifierがASCのアプリIDと一致しているか確認
5. 実機またはシミュレータで通知許可、カード取得、スワイプ、Wikipediaリンク、広告枠を確認
6. Archiveを作成し、OrganizerからApp Store Connectへアップロード
7. `ASC_Submission_Assets/screenshots` のスクショをASCへ登録
8. `metadata_ja.md` の文言をASCへ入力

## 生成済み素材
- アイコン: `KyoNoIjin/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png`
- 6.7インチ用スクショ: `ASC_Submission_Assets/screenshots/*_iphone_6_7_*.png`
- 6.5インチ用スクショ: `ASC_Submission_Assets/screenshots/*_iphone_6_5_*.png`

## こちらで完了できなかったこと
この環境はWindowsで、Xcode、Apple Developerの署名、App Store Connectログインが使えません。Archive作成とASCへの実アップロードはMacのXcodeで行ってください。
