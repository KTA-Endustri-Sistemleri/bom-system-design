# BOM System Design Draft

![Status](https://img.shields.io/badge/status-draft-orange)

ERPNext için **Kablo, Terminal ve Kalıp ilişkilerini otomatik çözümleyen** BOM tasarımı.  
Bu çalışma, fikir geliştirme aşamasında olup, ileride ERPNext uygulaması olarak genişletilecektir.

## 🎯 Amaç
- Kullanıcı BOM’a yalnızca item kodlarını girer.
- Sistem ilişkileri çözer ve doğru **operasyon + workstation** kombinasyonunu otomatik üretir.
- Manuel eşleştirmeler ortadan kalkar, hata riski azalır.

## 🗂 Ana Bileşenler
- **Kalıplar (KL-XXXX):** Çoklu terminal, çoklu workstation desteği.
- **Terminaller (100-Terminals):** Sıyırma değerleri, uyumlu kalıp & kablo bilgisi.
- **Kablolar (200-Cables & Wires):** Crimp yükseklik değeri, uyumlu terminaller.

## 🔗 İlişkiler
- Kalıp ↔ Terminal (**many-to-many**)
- Terminal ↔ Kablo (**many-to-many**)
- Kalıp ↔ Workstation (**many-to-many**)

## ⚙️ Çalışma Mantığı
1. Kullanıcı herhangi bir item seçer (Kablo / Terminal / Kalıp).
2. Sistem eşleşmeleri daraltarak **tek doğru kombinasyonu** bulur.
3. Kalıp üzerinden workstation atanır:
   - Tek workstation → otomatik atanır.
   - Çok workstation → kullanıcı seçer.

## ✅ Kazanımlar
- Daha az manuel işlem
- Daha düşük hata oranı
- Sade ve net **Job Card** görünümü
- Deterministik eşleşme sayesinde tam otomasyon

---

## 🚀 Milestones
### Milestone 1: Modelleme
- [ ] DocType tasarımlarının çıkarılması (Mould, Terminal, Cable)
- [ ] Many-to-many ilişki tablolarının belirlenmesi

### Milestone 2: BOM Entegrasyonu
- [ ] BOM Operation’a `custom_mould` alanının eklenmesi
- [ ] Hook: BOM save sırasında otomatik eşleşme fonksiyonları

### Milestone 3: Operasyon & Workstation
- [ ] Workstation seçim algoritması (tek → otomatik, çok → seçim)
- [ ] Operasyon satırında birleşik görünüm

### Milestone 4: Test & Doğrulama
- [ ] Dummy veri ile (C-0001, T-0001, KL-0001) test
- [ ] Job Card üzerinde operasyon çıktısının kontrolü

---

## 📌 Durum
Bu repo şu anda **fikir geliştirme aşamasındadır**.  
Boilerplate kod ve JSON dosyaları ilerleyen milestone’larda eklenecektir.
