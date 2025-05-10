# Pythonカレンダーアプリ

FastAPI + Jinja2 + SQLite を使った、シンプルな月間カレンダーアプリ

---

## 技術スタック

- **FastAPI**：軽量なPython製Web APIフレームワーク
- **Jinja2**：HTMLテンプレートレンダリング
- **SQLite + SQLAlchemy**：軽量な組み込みDB + ORM
- **Docker / docker-compose**：ローカル環境構築用

---

## ディレクトリ構成

```
calendar-app/
├── app/
│   ├── main.py               # FastAPIアプリ本体
│   ├── views.py              # テンプレート描画ロジック
│   ├── models.py             # SQLAlchemyモデル定義
│   ├── database.py           # DB接続と操作関数
│   ├── static/               # CSSなど静的ファイル
│   │   └── style.css
│   └── templates/            # Jinja2テンプレート
│       └── calendar.html
├── scripts/
│   └── seed_events.py        # 初期予定の投入スクリプト
├── Dockerfile                # アプリ用Docker設定
├── docker-compose.yml        # 開発用Docker Compose定義
├── requirements.txt          # Python依存ライブラリ
└── README.md                 # 本ファイル
```

---

## 起動手順

### 1. リポジトリをクローン

```bash
git clone git@github.com:de-developer-1/sample-calendar-app.git
```

### 2. Dockerで起動

```bash
docker-compose up --build
```

### 3. ブラウザで確認

[http://localhost:8000](http://localhost:8000)

---

## ✍️ 機能概要（MVP）

- 月ごとのカレンダー表示（現在月のみ）
- 予定の追加（フォームから登録）
- 予定のカレンダー表示（当日欄に表示）

---

## 初期データ投入（任意）

```bash
docker-compose run calendar python scripts/seed_events.py
```
