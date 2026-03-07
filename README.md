# 📊 University Poll System - Mobile Application

## 📝 Project Overview
This is a functional Flutter mobile application developed for the Week 2 Project Based Learning (PBL) assignment. The app allows users to create custom polls, categorize them, and vote on them in real-time. It is fully integrated with a cloud backend to ensure data persistence and live synchronization across devices.

## ✨ Key Features & Rubric Requirements Met

* **Firebase Integration (Backend):** Fully connected to Firebase Firestore. The app writes new polls to the cloud and listens for real-time updates using a `StreamBuilder`.
* **Form & Validation:** Implemented robust form validation using Flutter's `Form` and `GlobalKey<FormState>`. Users are prevented from submitting empty questions.
* **Structured Data Storage:** Documents are stored in Firestore with mandatory fields:
    1. `question` (String)
    2. `votes` (Integer)
    3. `category` (String)
    4. `createdAt` (Timestamp)
* **Data Display & UI:** The UI dynamically displays stored data in a clean `ListView`. It includes real-time vote counters and a "Total Votes" summary bar.

## 🛠️ Technology Stack
* **Frontend:** Flutter / Dart
* **Backend:** Firebase Cloud Firestore

