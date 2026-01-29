# 📺 YouTube TV Desktop Installer

> **เปลี่ยนคอมพิวเตอร์ของคุณให้กลายเป็น `Smart TV` ระดับ `High-End` ด้วยคลิกเดียว**
> *Developed by `IT Groceries Shop`*

![Version](https://img.shields.io/badge/version-v2.0_Build_72_(29--1--2026)-red?style=for-the-badge&logo=youtube)
![Platform](https://img.shields.io/badge/platform-Windows_10%2F11-blue?style=for-the-badge&logo=windows)
![Tech](https://img.shields.io/badge/Powered_By-PowerShell_WPF-green?style=for-the-badge&logo=powershell)

---

## 📸 ผลลัพธ์ที่ได้ (Preview)

เปลี่ยนหน้าเว็บ `YouTube` ธรรมดา ให้กลายเป็น `**TV Interface (Leanback)**` ที่ใช้งานง่าย สะอาดตา และรองรับการสั่งงานผ่านรีโมทหรือคีย์บอร์ดเต็มรูปแบบ พร้อมระบบ `**Always-On**` เล่นต่อเนื่องไม่มีสะดุด

![YouTube TV Interface](https://github.com/user-attachments/assets/4cc8993f-feab-445b-ae97-59c3443fa17b)

---

## 🚀 ฟีเจอร์เด่น (New Features)

* **⚡ New UI Design:** อินเทอร์เฟซแบบใหม่ `(Dark Theme)` สวยงาม ทันสมัย เขียนด้วย `**WPF**` แท้ๆ ไม่พึ่งพา `Library` ภายนอก
* **📂 Auto Icon Loader:** ระบบดึงไอคอน `Browser` สวยๆ จาก `Server` อัตโนมัติ (ไม่ต้องใช้ไอคอนแตกๆ จากไฟล์ `exe`)
* **🌍 7 Browsers Support:** รองรับเว็บเบราว์เซอร์ยอดนิยมถึง `7` ตัว:

    - <img src="https://raw.githubusercontent.com/itgroceries-sudo/Youtube-On-TV/main/IconFiles/Chrome.ico" width="20" height="20" style="vertical-align:middle; margin-right:5px;"/> **Google Chrome**
    - <img src="https://raw.githubusercontent.com/itgroceries-sudo/Youtube-On-TV/main/IconFiles/Edge.ico" width="20" height="20" style="vertical-align:middle; margin-right:5px;"/> **Microsoft Edge**
    - <img src="https://raw.githubusercontent.com/itgroceries-sudo/Youtube-On-TV/main/IconFiles/Brave.ico" width="20" height="20" style="vertical-align:middle; margin-right:5px;"/> **Brave Browser**
    - <img src="https://raw.githubusercontent.com/itgroceries-sudo/Youtube-On-TV/main/IconFiles/Vivaldi.ico" width="20" height="20" style="vertical-align:middle; margin-right:5px;"/> **Vivaldi**
    - <img src="https://raw.githubusercontent.com/itgroceries-sudo/Youtube-On-TV/main/IconFiles/Yandex.ico" width="20" height="20" style="vertical-align:middle; margin-right:5px;"/> **Yandex Browser**
    - <img src="https://raw.githubusercontent.com/itgroceries-sudo/Youtube-On-TV/main/IconFiles/Chromium.ico" width="20" height="20" style="vertical-align:middle; margin-right:5px;"/> **Chromium**
    - <img src="https://raw.githubusercontent.com/itgroceries-sudo/Youtube-On-TV/main/IconFiles/Thorium.ico" width="20" height="20" style="vertical-align:middle; margin-right:5px;"/> **Thorium**
 
* **🛠️ Manual Construction:** ระบบสร้างปุ่มด้วยมือ `(Manual Build)` การันตีความเสถียร 100% ไอคอนไม่หาย หน้าต่างไม่เด้ง
* **🤖 Pre-Loader System:** ระบบตรวจสอบและดาวน์โหลดไฟล์ที่จำเป็นให้ครบก่อนเปิดโปรแกรม ป้องกันข้อผิดพลาด

---

## 💻 วิธีการติดตั้ง (Installation)

### แบบรวดเร็ว (One-Line Command)
เปิด `**PowerShell**` หรือ `**Terminal**` แล้ววางคำสั่งนี้:

```powershell
iex(irm bit.ly/YToTV)
```

*หรือ*
```Terminal
irm bit.ly/YToTV | iex
```

แล้วกด `**Enter**`

---

## 🚀 แบบเทพ (Hxckerman / Silent Mode)

> **เหมาะสำหรับ:** `ช่างคอม`, `แอดมิน`, หรือสคริปต์ติดตั้ง Windows อัตโนมัติ
>> **Autounattend.xml:** สำหรับงานติดตั้ง `Windows` แบบอัตโนมัติ
>>> *คำสั่งเหล่านี้จะลงให้ทันที `**โดยไม่ถาม**` และไม่มีหน้าต่างเด้งขึ้นมาตอนจบ*

# 🔵 กลุ่มมาตรฐาน (Standard)

- ### <img src="https://raw.githubusercontent.com/itgroceries-sudo/Youtube-On-TV/main/IconFiles/Edge.ico" width="20" height="20" style="vertical-align:middle; margin-right:5px;"/> สำหรับ Microsoft Edge 
```powershell
& ([scriptblock]::Create((irm bit.ly/YToTV))) -Browser Edge -Silent
```
- ### <img src="https://raw.githubusercontent.com/itgroceries-sudo/Youtube-On-TV/main/IconFiles/Chrome.ico" width="20" height="20" style="vertical-align:middle; margin-right:5px;"/> สำหรับ Google Chrome
```powershell
& ([scriptblock]::Create((irm bit.ly/YToTV))) -Browser Chrome -Silent
```
- ### <img src="https://raw.githubusercontent.com/itgroceries-sudo/Youtube-On-TV/main/IconFiles/Brave.ico" width="20" height="20" style="vertical-align:middle; margin-right:5px;"/> สำหรับ Brave Browser (แนะนำ!)
```powershell
& ([scriptblock]::Create((irm bit.ly/YToTV))) -Browser Brave -Silent
```

# 🔴 กลุ่มทางเลือก (Alternative)
- ### <img src="https://raw.githubusercontent.com/itgroceries-sudo/Youtube-On-TV/main/IconFiles/Vivaldi.ico" width="20" height="20" style="vertical-align:middle; margin-right:5px;"/> สำหรับ Vivaldi
```powershell
& ([scriptblock]::Create((irm bit.ly/YToTV))) -Browser Vivaldi -Silent
```
- ### <img src="https://raw.githubusercontent.com/itgroceries-sudo/Youtube-On-TV/main/IconFiles/Yandex.ico" width="20" height="20" style="vertical-align:middle; margin-right:5px;"/> สำหรับ Yandex
```powershell
& ([scriptblock]::Create((irm bit.ly/YToTV))) -Browser Yandex -Silent
```

# ⚪ กลุ่มโอเพนซอร์ส (Open Source)
- ### <img src="https://raw.githubusercontent.com/itgroceries-sudo/Youtube-On-TV/main/IconFiles/Chromium.ico" width="20" height="20" style="vertical-align:middle; margin-right:5px;"/> สำหรับ Chromium
```powershell
& ([scriptblock]::Create((irm bit.ly/YToTV))) -Browser Chromium -Silent
```
- ### <img src="https://raw.githubusercontent.com/itgroceries-sudo/Youtube-On-TV/main/IconFiles/Thorium.ico" width="20" height="20" style="vertical-align:middle; margin-right:5px;"/> สำหรับ Thorium
```powershell
& ([scriptblock]::Create((irm bit.ly/YToTV))) -Browser Thorium -Silent
```

### ⚙️ คำอธิบาย Parameter
* **`-Browser [Name]`** : สั่งเจาะจง Browser ที่จะลง (`Edge`, `Chrome`, `Brave``Opera`,`OperaGX`,`Vivaldi`,`Yandex`)
* **`-Silent`** : ทำงานเงียบๆ ไม่ต้องแสดง `**Message Box**` เมื่อเสร็จสิ้น

---

## 📝 ขั้นตอนการใช้งาน (Step-by-Step)

### 1. ติ๊กเลือกเบราว์เซอร์ (Select & Create)
เมื่อเปิดโปรแกรม:
1.  เลือก `*Browser*` ที่คุณต้องการใช้จากเมนู `*Switch**`
2.  กดปุ่ม `Start` เพื่อ `Create Shortcut`

![Installer GUI](https://github.com/user-attachments/assets/450e7691-4548-46b7-8cc0-c3001e8d4f11)

*(รูปที่ 2: เลือก `Browser` แล้วกดปุ่มได้เลย)*

### 2. เสร็จสิ้น (Finish)
โปรแกรมจะแจ้งว่า *`"Created!"`* ทันที (ใช้เวลาไม่ถึง 2 วินาที)
คุณจะพบ Shortcut ชื่อ *`Youtube On TV`* บนหน้าจอ พร้อมไอคอนสีแดงสวยงาม

![Success Screen](https://github.com/user-attachments/assets/8d32015a-c794-467a-8f78-fca5dea9e49b)

*(รูปที่ 3: `Shortcut` ถูกสร้างเรียบร้อย)*

![Success Screen](https://github.com/user-attachments/assets/69970f7c-e2d8-4a56-84c3-5c615e6251d0)

*(รูปที่ 4: `Shortcut` ถูกสร้างบน `Desktop`)*


### 3. การเข้าใช้งาน (Launch)
เมื่อดับเบิ้ลคลิก Shortcut:
1.  ระบบจะปิด *`Browser*` ตัวนั้นๆ ที่เปิดค้างอยู่ทันที (เพื่อเคลียร์ค่า)
2.  เปิดหน้าจอ *`YouTube TV*` ขึ้นมาพร้อมใช้งาน

![YouTube TV](https://github.com/user-attachments/assets/bf26eae8-3ef6-4ae3-8053-2c61bb6556bc)

*(รูปที่ 5: หน้าจอ `YouTube TV` พร้อมใช้งาน)*

<br>

<div align="center">

**Developed with ❤️ by `IT Groceries Shop`**
