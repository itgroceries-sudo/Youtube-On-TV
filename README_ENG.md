# 📺 YouTube TV Desktop Installer

> **Transform your computer into a `High-End` `Smart TV` with a single click.**
> *Developed by `IT Groceries Shop`*

![Version](https://img.shields.io/badge/version-v2.0_Build_75.6.6_(4--2--2026)-red?style=for-the-badge&logo=youtube)
![Platform](https://img.shields.io/badge/platform-Windows_10%2F11-blue?style=for-the-badge&logo=windows)
![Tech](https://img.shields.io/badge/Powered_By-PowerShell_WPF-green?style=for-the-badge&logo=powershell)

---

## 📸 Preview

Transforms the standard `YouTube` web page into a clean, user-friendly `**TV Interface (Leanback)**`. Fully supports remote control and keyboard navigation, featuring an `**Always-On**` system for seamless, uninterrupted playback.

![YouTube TV Interface](https://github.com/user-attachments/assets/4cc8993f-feab-445b-ae97-59c3443fa17b)

<img width="1161" height="879" alt="image" src="https://github.com/user-attachments/assets/6d345e37-040d-4501-a7cd-fedf62cfbf59" />

---

## 🚀 Release v2.0 Build 23.75.6.6 (Ultimate Edition)

**What's New:**
* 🎨 **New UI Design:** Modern Vector Icons, Dark Theme, and Card-style layout.
* 🖱️ **Interactive UX:** Added sound effects (Click, Tick, Warning, Done).
* ⚙️ **Full Control Options:** * Toggle Uninstall Mode (Trash Icon).
    * Toggle Start Menu Shortcut (Windows Icon).
    * Toggle Desktop Shortcut (Desktop Icon) - *New!*
* 🖥️ **Console Upgrade:** Fixed "No-Close" console window for better stability.
* 🐞 **Bug Fixes:** Resolved crash issues on admin request and added feedback for missing uninstall targets.

---

## 🚀 Key Features

* **⚡ New UI Design:** Sleek, modern interface `(Dark Theme)` built with native `**WPF**`. Zero external `Library` dependencies.
* **📂 Auto Icon Loader:** Automatically fetches high-quality `Browser` icons from the `Server` (No more pixelated icons extracted from `exe` files).
* **🌍 7 Browsers Support:** Supports `7` popular web browsers:

    - <img src="https://raw.githubusercontent.com/itgroceries-sudo/Youtube-On-TV/main/IconFiles/Chrome.ico" width="20" height="20" style="vertical-align:middle; margin-right:5px;"/> **Google Chrome**
    - <img src="https://raw.githubusercontent.com/itgroceries-sudo/Youtube-On-TV/main/IconFiles/Edge.ico" width="20" height="20" style="vertical-align:middle; margin-right:5px;"/> **Microsoft Edge**
    - <img src="https://raw.githubusercontent.com/itgroceries-sudo/Youtube-On-TV/main/IconFiles/Brave.ico" width="20" height="20" style="vertical-align:middle; margin-right:5px;"/> **Brave Browser**
    - <img src="https://raw.githubusercontent.com/itgroceries-sudo/Youtube-On-TV/main/IconFiles/Vivaldi.ico" width="20" height="20" style="vertical-align:middle; margin-right:5px;"/> **Vivaldi**
    - <img src="https://raw.githubusercontent.com/itgroceries-sudo/Youtube-On-TV/main/IconFiles/Yandex.ico" width="20" height="20" style="vertical-align:middle; margin-right:5px;"/> **Yandex Browser**
    - <img src="https://raw.githubusercontent.com/itgroceries-sudo/Youtube-On-TV/main/IconFiles/Chromium.ico" width="20" height="20" style="vertical-align:middle; margin-right:5px;"/> **Chromium**
    - <img src="https://raw.githubusercontent.com/itgroceries-sudo/Youtube-On-TV/main/IconFiles/Thorium.ico" width="20" height="20" style="vertical-align:middle; margin-right:5px;"/> **Thorium**

* **🛠️ Manual Construction:** Hand-coded button architecture `(Manual Build)` guarantees 100% stability. No missing icons, no random crashes.
* **🤖 Pre-Loader System:** Automatically verifies and downloads all essential assets before launch to prevent errors.

---

## 💻 Installation

### Quick Install (One-Line Command)
Open `**PowerShell**` or `**Terminal**` and paste the following command:

```powershell
iex(irm bit.ly/YToTV)
```

*Or*
```Terminal
irm bit.ly/YToTV | iex
```

Then Press `**Enter**`

---

## 🚀 Pro Mode (Hxckerman / Silent Mode)

> **Suitable for:** IT Technicians, System Admins, or automated Windows installation scripts.
>> **Autounattend.xml:** Ideal for automated Windows deployment.
>>> *These commands will install immediately **without prompting** and suppress the final pop-up window.*

# 🔵 Standard

- ### <img src="https://raw.githubusercontent.com/itgroceries-sudo/Youtube-On-TV/main/IconFiles/Edge.ico" width="20" height="20" style="vertical-align:middle; margin-right:5px;"/> For Microsoft Edge
```powershell
& ([scriptblock]::Create((irm bit.ly/YToTV))) -Browser Edge -Silent
```
- ### <img src="https://raw.githubusercontent.com/itgroceries-sudo/Youtube-On-TV/main/IconFiles/Chrome.ico" width="20" height="20" style="vertical-align:middle; margin-right:5px;"/> For Google Chrome
```powershell
& ([scriptblock]::Create((irm bit.ly/YToTV))) -Browser Chrome -Silent
```
- ### <img src="https://raw.githubusercontent.com/itgroceries-sudo/Youtube-On-TV/main/IconFiles/Brave.ico" width="20" height="20" style="vertical-align:middle; margin-right:5px;"/> For Brave Browser (แนะนำ!)
```powershell
& ([scriptblock]::Create((irm bit.ly/YToTV))) -Browser Brave -Silent
```
# 🔴 Alternatives

- ### <img src="https://raw.githubusercontent.com/itgroceries-sudo/Youtube-On-TV/main/IconFiles/Vivaldi.ico" width="20" height="20" style="vertical-align:middle; margin-right:5px;"/> For Vivaldi
```powershell
& ([scriptblock]::Create((irm bit.ly/YToTV))) -Browser Vivaldi -Silent
```
- ### <img src="https://raw.githubusercontent.com/itgroceries-sudo/Youtube-On-TV/main/IconFiles/Yandex.ico" width="20" height="20" style="vertical-align:middle; margin-right:5px;"/> For Yandex
```powershell
& ([scriptblock]::Create((irm bit.ly/YToTV))) -Browser Yandex -Silent
```
# ⚪ Open Source
- ### <img src="https://raw.githubusercontent.com/itgroceries-sudo/Youtube-On-TV/main/IconFiles/Chromium.ico" width="20" height="20" style="vertical-align:middle; margin-right:5px;"/> For Chromium
```powershell
& ([scriptblock]::Create((irm bit.ly/YToTV))) -Browser Chromium -Silent
```
- ### <img src="https://raw.githubusercontent.com/itgroceries-sudo/Youtube-On-TV/main/IconFiles/Thorium.ico" width="20" height="20" style="vertical-align:middle; margin-right:5px;"/> For Thorium
```powershell
& ([scriptblock]::Create((irm bit.ly/YToTV))) -Browser Thorium -Silent
```

### ⚙️ Parameter Descriptions
* **`-Browser [Name]`** : Specifies the target Browser (`Edge`, `Chrome`, `Brave`, `Opera`, `OperaGX`, `Vivaldi`, `Yandex`).
* **`-Silent`** : Runs silently without displaying a `**Message Box**` upon completion.

---

## 📝 Usage (Step-by-Step)

### 1. Select & Create
Upon launching the program:
1. Toggle the `*Switch**` next to your desired `*Browser*`.
2. Click the `Start` button to `Create Shortcut`.

![Installer GUI](https://github.com/user-attachments/assets/93d30495-c3de-4eb2-9440-502a3d663bab)

*(Fig 2: Select your `Browser` and click the button)*

### 2. Finish
The program will immediately notify you with *`"Created!"`* (takes less than 2 seconds).
You will find a shortcut named *`Youtube On TV`* on your desktop, complete with a beautiful red icon.

![Success Screen](https://github.com/user-attachments/assets/92ce71e9-aaca-40c7-b339-3d4356b00fed)

*(Fig 3: `Shortcut` created successfully)*

![Success Screen](https://github.com/user-attachments/assets/69970f7c-e2d8-4a56-84c3-5c615e6251d0)

*(Fig 4: `Shortcut` created on `Desktop`)*

### 3. Launch
When you double-click the Shortcut:
1. The system will immediately close any active instances of that *`Browser*` (to clear the session).
2. Launches the *`YouTube TV*` interface, ready for use.

![YouTube TV](https://github.com/user-attachments/assets/bf26eae8-3ef6-4ae3-8053-2c61bb6556bc)

*(Fig 5: `YouTube TV` interface ready for use)*

<br>

<div align="center">

**Developed with ❤️ by `IT Groceries Shop`**
