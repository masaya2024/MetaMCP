/**
 * スプレッドシートに6シートを作成し、列ヘッダーを設定する
 * 使い方:
 *   1. スプレッドシートを開く
 *   2. 拡張機能 > Apps Script を開く
 *   3. このコードを貼り付けて実行（setupAllSheets）
 */
function setupAllSheets() {
  var ss = SpreadsheetApp.getActiveSpreadsheet();

  var sheets = [
    {
      name: "実績ログ_キャンペーン",
      headers: [
        "日付", "キャンペーン名", "表示回数", "クリック数",
        "費用", "CV", "CPA", "CVR", "CTR", "CPM",
        "アクション・METAステータス", "LP利用"
      ]
    },
    {
      name: "実績ログ_クリエイティブ",
      headers: [
        "日付", "キャンペーン名", "広告セット名", "広告ID", "広告名",
        "表示回数", "クリック数", "費用", "CV", "CTR", "CVR", "CPA"
      ]
    },
    {
      name: "クリエイティブ・マスタ",
      headers: [
        "広告ID", "広告名", "種類", "メイン訴求", "サブ訴求",
        "ターゲット属性", "見出し（30文字）", "説明文（90文字）",
        "メインテキスト", "バナー構成/動画台本", "特徴",
        "ステータス", "作成日", "デザインURL", "AI識別タグ"
      ]
    },
    {
      name: "運用変更ログ",
      headers: [
        "日付", "対象キャンペーン・広告セット", "変更種別",
        "変更内容", "理由・仮説", "学習状態", "結果_7日後"
      ]
    },
    {
      name: "承認・FBログ",
      headers: [
        "提案日", "提案タイトル", "判定",
        "FB詳細（理由）", "当時の状況", "決定アクション"
      ]
    },
    {
      name: "ナレッジDB",
      headers: [
        "更新日", "訴求軸・要素", "成功要因（勝ち）",
        "失敗要因（負け）", "次回の黄金ルール", "適用条件",
        "信頼スコア", "検証回数"
      ]
    }
  ];

  sheets.forEach(function(sheetDef) {
    var sheet = ss.getSheetByName(sheetDef.name);
    if (!sheet) {
      sheet = ss.insertSheet(sheetDef.name);
    }
    var headerRange = sheet.getRange(1, 1, 1, sheetDef.headers.length);
    headerRange.setValues([sheetDef.headers]);
    headerRange.setFontWeight("bold");
    headerRange.setBackground("#FFFFFF");
    headerRange.setFontColor("#000000");
    sheet.setFrozenRows(1);
    sheet.autoResizeColumns(1, sheetDef.headers.length);
  });

  // デフォルトの「シート1」を削除（他のシートがあれば）
  var defaultSheet = ss.getSheetByName("シート1");
  if (defaultSheet && ss.getSheets().length > 1) {
    ss.deleteSheet(defaultSheet);
  }

  SpreadsheetApp.getUi().alert("セットアップ完了！6シートが作成されました。");
}

