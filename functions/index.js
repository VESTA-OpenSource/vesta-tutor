const { onRequest } = require("firebase-functions/v2/https");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

// 🚀 Inicializamos el núcleo administrativo de Firebase en el servidor
admin.initializeApp();

exports.enviarNotificacionAlerta = onDocumentCreated("alerts/{alertId}", async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
        console.log("❌ Error: No se encontraron datos en el evento.");
        return null;
    }

    // 1. Extraemos los datos de la infracción que el hijo cometió
    const dataAlerta = snapshot.data();
    const tutorId = dataAlerta.tutorId;
    const titulo = dataAlerta.title || "Incidente Detectado";
    const subtitulo = dataAlerta.subtitle || "Vesta ha bloqueado un acceso no seguro.";
    const tipoRiesgo = dataAlerta.type || "critical"; 

    console.log(`🔍 Procesando alerta para el Tutor: ${tutorId}. Tipo: ${tipoRiesgo}`);

    try {
        const tutorDoc = await admin.firestore().collection("users").doc(tutorId).get();
        
        if (!tutorDoc.exists) {
            console.log(`⚠️ El documento del tutor ${tutorId} no existe en Firestore.`);
            return null;
        }

        const fcmToken = tutorDoc.data().fcmToken;

        if (!fcmToken) {
            console.log(`🔴 El tutor ${tutorId} no tiene un fcmToken registrado en su celular.`);
            return null;
        }

        const mensajePush = {
            token: fcmToken,
            notification: {
                title: `🚨 VESTA: ${titulo}`,
                body: subtitulo,
            },
            android: {
                priority: "high",
                notification: {
                    sound: "default",
                    clickAction: "FLUTTER_NOTIFICATION_CLICK", // Abre la app al presionar el globo
                    color: tipoRiesgo === "critical" ? "#E03131" : "#FCC419", // Tinte visual nativo
                },
            },
            data: {
                click_action: "FLUTTER_NOTIFICATION_CLICK",
                type: tipoRiesgo,
                tutorId: tutorId
            }
        };

        const response = await admin.messaging().send(mensajePush);
        console.log(`🚀 ¡Notificación Push enviada con éxito! ID de Google: ${response}`);
        return null;

    } catch (error) {
        console.error("❌ Error catastrófico al procesar el envío de la notificación:", error);
        return null;
    }
});