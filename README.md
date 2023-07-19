# fcm_netmera_local_notif

### Reproducable sample of FCM & Netmera & Local notifications

1. To reproduce the issue, update bundle id & GoogleService-Info.plist for your FCM project
2. Build the project & launch
3. Trigger a push notification (not a Netmera push)
4. Observe the app behavior & logs. There should be repetitive logs :

```
2023-07-19 12:34:21.651811+0200 Runner[655:39859] flutter: FCM onMessage
2023-07-19 12:34:21.652366+0200 Runner[655:39859] flutter: Not a Netmera push. SuperApp will handle it
2023-07-19 12:34:21.653127+0200 Runner[655:39859] flutter: Push notification received in the foreground
2023-07-19 12:34:21.658501+0200 Runner[655:39859] flutter: FCM onMessage
2023-07-19 12:34:21.658799+0200 Runner[655:39859] flutter: Not a Netmera push. SuperApp will handle it
2023-07-19 12:34:21.658922+0200 Runner[655:39859] flutter: Push notification received in the foreground
2023-07-19 12:34:21.660010+0200 Runner[655:39859] flutter: FCM onMessage
.
.
.
```
