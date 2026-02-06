# BOM System Design

ERPNext içinde çalışan **kablo demeti (wire harness) tasarım ve üretim BOM oluşturma aracı**.

Bu proje klasik BOM giriş ekranı değildir.
Bu sistem mühendislerin bileşenleri yerleştirip pinleri bağlayarak tasarım yapmasını sağlar.
Sistem tasarımı doğrular, diyagram üretir ve ERPNext’e üretim BOM’u gönderir.

---

## Amaç

Karmaşık kablo demetleri ERP içinde satır satır yazılarak oluşturulamaz.
Bu proje:

- Connector
- Cable
- Terminal
- Splice

gibi bileşenlerden görsel olarak bir bağlantı ağı kurar.

Sonuç:
- Graphviz diyagramı
- Üretilebilir BOM
- Doğrulanmış bağlantı listesi

---

## Temel Kavramlar

### Spec Driven Items
Her item kendi mühendislik bilgisini taşır.

| Tip | Örnek Alanlar |
|---|---|
| Connector | pin_labels, pitch, gender |
| Cable | wire_count, colors, shield |
| Terminal | crimp_range, material |
| Splice | type, sealed |

---

### Connection Graph
Sistem BOM değil, bir **bağlantı grafı** tutar.

Pin → Pin bağlantıları
Wire → Terminal ilişkileri
Connector → Cable mapping

---

### Validation Engine
Tasarım yapılırken kontrol edilir:

- Pin sayısı uyumsuzluğu
- Wire count hataları
- Uygun olmayan terminal
- Shield continuity

---

### Diagram Generator
Graphviz ile otomatik şema üretir.

---

### BOM Generator
Son adımda ERPNext Manufacturing BOM oluşturulur.

---

## Workflow

1) Bileşenleri yerleştir
2) Pinleri bağla
3) Doğrula
4) Diyagram üret
5) BOM export

---

## Mimari

Frontend: Vue Canvas UI  
Backend: Frappe API  
Engine: Graph model + validation  
Output: Graphviz + ERPNext BOM

---

## Bu proje ne değildir

- Klasik ERP BOM girişi değildir
- Üretim operasyon planlayıcı değildir
- Kural motoru değildir

Bu bir mühendislik tasarım aracıdır.

---

## Roadmap

Detaylı plan için:
MILESTONES.md