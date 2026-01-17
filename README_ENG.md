# 📺 YouTube TV Desktop Installer

> **Transform your computer into a High-End Smart TV with a single click.**
> *Developed by IT Groceries Shop*

![Version](https://img.shields.io/badge/version-7.2.0-red?style=for-the-badge&logo=youtube)
![Platform](https://img.shields.io/badge/platform-Windows_10%2F11-blue?style=for-the-badge&logo=windows)
![Tech](https://img.shields.io/badge/Powered_By-PowerShell_%2B_Batch-black?style=for-the-badge&logo=powershell)
![Browser](https://img.shields.io/badge/Support-Brave_%7C_Chrome_%7C_Edge-0078D7?style=for-the-badge&logo=microsoft-edge)

---

## 📸 Preview

Transforms the standard YouTube web interface into a clean, easy-to-use **TV Interface (Leanback)**. Fully supports remote control or keyboard navigation, featuring an **Always-On** system for uninterrupted playback.

![YouTube TV Interface](https://github.com/user-attachments/assets/4cc8993f-feab-445b-ae97-59c3443fa17b)
*(Figure 1: The beautiful YouTube TV Mode interface after installation)*

---

## 🚀 Introduction

**YouTube TV Installer** is a smart tool designed to "unlock" the **TV Mode** interface on your computer by simulating the latest Smart TV User-Agent (Samsung Tizen).

Perfect for:
* 🖥️ **HTPC (Home Theater PC):** Connect your PC to a large TV screen.
* 🎮 **Mini PC / Console:** Easy control via game controllers.
* ✨ **Minimalist:** For those who love a clean, dark aesthetic with large, accessible buttons.

---

## 💎 Key Features

| Feature | Description |
| :---- | :---- |
| **⚡ Instant Creation** | **Fastest!** Instantly create shortcuts **without opening the browser**. No need to wait for user installation prompts. |
| **🌍 Universal TV Mode** | Uses the latest 2025 User-Agent standard (**Samsung Tizen 9.0**). Fully supports **Brave**, **Chrome**, and **Edge**. |
| **⚔️ Universal Auto-Kill** | **(New!)** Every shortcut embeds a **"Force Close Previous Browser"** command before launching. Guarantees 100% TV Mode functionality. |
| **🎨 Custom Icon Injection** | Directly fetches a high-quality YouTube icon from the server (No more generic white paper or default browser icons). |
| **🎵 Background Play** | **(Anti-Freeze)** Embeds commands to prevent video playback from stopping when minimized or covered by other windows. |

---

## ⚙️ How It Works (Technical Deep Dive)

This script operates via **Direct Injection** without relying on the browser to generate files:

1.  **The Selector:** User selects an installed browser.
2.  **The Creator:** Uses `WScript.Shell` to create a `.lnk` (Shortcut) on the Desktop.
3.  **The Wrapper:** The resulting shortcut doesn't call the browser directly. It routes through `CMD` to:
    * Execute `taskkill /f /im [browser].exe` to clear old processes.
    * Execute `start` to open the browser with specific arguments (`--app`, `--user-agent` Tizen, `--disable-occlusion`).
4.  **The Finisher:** Injects the `YouTube.ico` loaded from the cloud into the file.

---

## 💻 Installation

### Quick Install (One-Line Command)
Open **PowerShell** or Terminal and paste this command:

```powershell
iex(irm bit.ly/YToTV)
```

*OR*
```Terminal
irm bit.ly/YToTV | iex
```

---

## 🚀 Advanced Mode (Silent / SysAdmin)

> **Perfect for:** IT Technicians, System Admins, or Automated Windows Installation Scripts.
>> **Autounattend.xml:** Ideal for automated Windows deployment.
>>> *These commands install immediately without prompts or pop-ups.*

### 🔵 For Microsoft Edge (Recommended!)
```powershell
& ([scriptblock]::Create((irm bit.ly/YToTV))) -Browser Edge -Silent
```
### 🟡 For Google Chrome
```powershell
& ([scriptblock]::Create((irm bit.ly/YToTV))) -Browser Chrome -Silent
```
### 🟠 For Brave Browser
```powershell
& ([scriptblock]::Create((irm bit.ly/YToTV))) -Browser Brave -Silent
```
### ⚙️ Parameter Explanation
* **`-Browser [Name]`** : Specifies the target browser (`Edge`, `Chrome`, `Brave`)
* **`-Silent`** : Runs quietly without showing a Message Box upon completion.

## 📝 Step-by-Step Guide
### 1. Select & Create
When the program opens:
1.  Select your preferred browser from the Dropdown menu.
2.  Click the "Create Shortcut" button.

![Installer GUI](https://github.com/user-attachments/assets/fb40e77c-6615-4422-b448-8390ad39e3bd)

(Figure 2: Select a browser and click the button)

### 2. Finish
The program will instantly report "Success!" (takes less than 2 seconds). You will find a shortcut named Youtube On TV on your desktop with a beautiful red icon.

![Success Screen](https://github.com/user-attachments/assets/71537814-5b4f-44d8-8741-3ae30b507796)

(Figure 3: Shortcut successfully created)

### 3. Launch
When double-clicking the shortcut:
1.  The system will immediately close any running instances of that browser (to clear session/cache).
2.  Opens the YouTube TV interface, ready to use.

![YouTube TV](https://github.com/user-attachments/assets/bf26eae8-3ef6-4ae3-8053-2c61bb6556bc)

(Figure 4: YouTube TV Mode ready for action)

<br>

<div align="center">

Developed with ❤️ by IT Groceries Shop

</div>
