---
name: fomo-app project context
description: Fomo App — Expo React Native 社交活動探索 app，agent 團隊設定與 stack constraints
type: project
originSessionId: f01bfee0-1157-4830-92f6-8426b4552612
---
Fomo App 是一個社交活動探索 mobile app（FOMO = Fear Of Missing Out），位於 `~/fomo-app/`。

**Why:** James 正在製作這個 app；agent 團隊在 2026-04-09 建立。

**How to apply:** 任何 fomo-app 任務交給 📱 Fomo App Director 處理；Director 啟動時必讀 `~/fomo-app/CLAUDE.md` + `progress.md`。

## Stack

- Expo SDK 54 + React Native 0.81
- NativeWind v2（Tailwind for RN，用 `className` prop）
- React Navigation v7（Bottom Tabs + Native Stack）
- TanStack Query v5（server state）
- Zustand v5（client state）
- Axios + JWT + expo-secure-store（auth）
- i18next（i18n，所有文字走 `t()`）
- react-native-maps、react-native-qrcode-svg

## Screens

| 模組 | Screens |
|------|---------|
| Auth | Welcome, Login, Register, OnboardingDating |
| Home | HomeScreen, SearchScreen, EventDetail, CategoryList |
| Discover | Discover, PersonDetail, DatingFilter |
| Social | FriendActivity, FriendsList |
| Tickets | Tickets, MyTickets, TicketDetail, OrderHistory |
| Map | Map |
| Profile | Profile, EditProfile, DatingProfileEdit, MyEvents, Notifications, Settings |

## Key Files

- `~/fomo-app/CLAUDE.md` — stack constraints source of truth
- `~/fomo-app/progress.md` — 功能進度與 blockers
- `src/services/api.ts` — axios instance（唯一 HTTP 入口）
- `src/stores/authStore.ts` — auth Zustand store
- `src/stores/datingFilterStore.ts` — dating filter store
