import 'package:cloud_firestore/cloud_firestore.dart';

class SeedService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> seedDatabaseIfEmpty() async {
    try {
      final snapshot = await _db.collection('products').limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        print("💡 La base de datos ya contiene productos. No es necesario autopoblar.");
        return;
      }

      print("🌱 Autopoblando base de datos con 140 productos (14 categorías)...");
      final WriteBatch batch = _db.batch();
      final productsCollection = _db.collection('products');

      for (var p in _seedProducts) {
        final docRef = productsCollection.doc();
        batch.set(docRef, p);
      }

      await batch.commit();
      print("✅ ¡140 productos insertados exitosamente en Firestore!");
    } catch (e) {
      print("❌ Error al autopoblar base de datos: $e");
    }
  }

  static final List<Map<String, dynamic>> _seedProducts = [
    // 1. DEPORTES (10)
    {
      "name": "Balón de Fútbol Profesional",
      "description": "Balón de cuero sintético premium para entrenamientos y partidos de alta intensidad.",
      "price": 499.0,
      "image": "https://images.unsplash.com/photo-1508098682722-e99c43a406b2?w=500",
      "category": "Deportes",
      "subcategory": ""
    },
    {
      "name": "Mancuernas de Neopreno 5kg",
      "description": "Par de mancuernas ergonómicas ideales para fitness, yoga y tonificación.",
      "price": 389.0,
      "image": "https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=500",
      "category": "Deportes",
      "subcategory": ""
    },
    {
      "name": "Tapete de Yoga Antideslizante",
      "description": "Grosor de 6mm para máxima comodidad de articulaciones, incluye correa de transporte.",
      "price": 349.0,
      "image": "https://images.unsplash.com/photo-1592432678016-e910b452f9a2?w=500",
      "category": "Deportes",
      "subcategory": ""
    },
    {
      "name": "Bicicleta de Montaña R26",
      "description": "Bicicleta de aluminio de alta resistencia con 21 velocidades Shimano y doble amortiguador.",
      "price": 5499.0,
      "image": "https://images.unsplash.com/photo-1485965120184-e220f721d03e?w=500",
      "category": "Deportes",
      "subcategory": ""
    },
    {
      "name": "Raqueta de Tenis Avanzada",
      "description": "Estructura de fibra de carbono ligera para control excepcional y potencia de golpe.",
      "price": 1299.0,
      "image": "https://images.unsplash.com/photo-1595435934249-5df7ed86e1c0?w=500",
      "category": "Deportes",
      "subcategory": ""
    },
    {
      "name": "Gorra Deportiva Aerorready",
      "description": "Gorra transpirable de secado rápido ideal para correr y deportes al aire libre.",
      "price": 299.0,
      "image": "https://images.unsplash.com/photo-1534215754734-18e55d13ce35?w=500",
      "category": "Deportes",
      "subcategory": ""
    },
    {
      "name": "Bandas de Resistencia (Set de 5)",
      "description": "Bandas de látex natural con diferentes niveles de resistencia para piernas y glúteos.",
      "price": 199.0,
      "image": "https://images.unsplash.com/photo-1598289431512-b97b0917affc?w=500",
      "category": "Deportes",
      "subcategory": ""
    },
    {
      "name": "Proteína en Polvo Whey 1kg",
      "description": "Suplemento alimenticio sabor chocolate para recuperación muscular post-entrenamiento.",
      "price": 649.0,
      "image": "https://images.unsplash.com/photo-1579758629938-03607ccdbaba?w=500",
      "category": "Deportes",
      "subcategory": ""
    },
    {
      "name": "Lentes de Natación Antiempañantes",
      "description": "Protección UV y silicona suave a prueba de fugas para nadadores profesionales.",
      "price": 249.0,
      "image": "https://images.unsplash.com/photo-1519046904884-53103b34b206?w=500",
      "category": "Deportes",
      "subcategory": ""
    },
    {
      "name": "Reloj con Monitor de Ritmo Cardiaco",
      "description": "Mide pasos, calorías y sueño con notificaciones inteligentes y resistencia al agua.",
      "price": 899.0,
      "image": "https://images.unsplash.com/photo-1575311373937-040b8e1fd5b6?w=500",
      "category": "Deportes",
      "subcategory": ""
    },

    // 2. REGALOS (10)
    {
      "name": "Caja Regalo de Chocolates Gourmet",
      "description": "Selección de trufas artesanales rellenas, un detalle exquisito para ocasiones especiales.",
      "price": 320.0,
      "image": "https://images.unsplash.com/photo-1549007994-cb92ca714503?w=500",
      "category": "Regalos",
      "subcategory": ""
    },
    {
      "name": "Oso de Peluche Gigante 1 Metro",
      "description": "Suave, tierno y afelpado, perfecto para aniversarios, cumpleaños o San Valentín.",
      "price": 599.0,
      "image": "https://images.unsplash.com/photo-1559251606-c623743a6d76?w=500",
      "category": "Regalos",
      "subcategory": ""
    },
    {
      "name": "Kit de Velas Aromáticas de Soya",
      "description": "Juego de 4 fragancias relajantes: Lavanda, Sándalo, Rosas y Vainilla.",
      "price": 279.0,
      "image": "https://images.unsplash.com/photo-1603006905003-be475563bc59?w=500",
      "category": "Regalos",
      "subcategory": ""
    },
    {
      "name": "Álbum de Fotos de Aventura",
      "description": "Estilo Scrapbook vintage de cuero retro para pegar memorias, fotos y notas.",
      "price": 249.0,
      "image": "https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=500",
      "category": "Regalos",
      "subcategory": ""
    },
    {
      "name": "Taza Personalizada Mágica",
      "description": "Taza negra que revela tu foto o diseño preferido cuando le agregas líquido caliente.",
      "price": 149.0,
      "image": "https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=500",
      "category": "Regalos",
      "subcategory": ""
    },
    {
      "name": "Lámpara de Luna 3D Táctil",
      "description": "Lámpara recargable USB con control táctil y 16 colores LED para habitación acogedora.",
      "price": 350.0,
      "image": "https://images.unsplash.com/photo-1532926382873-e8917bb1bcb4?w=500",
      "category": "Regalos",
      "subcategory": ""
    },
    {
      "name": "Rosa Eterna de Vidrio con Luces",
      "description": "Inspirada en La Bella y la Bestia, rosa de seda iluminada que dura para siempre.",
      "price": 399.0,
      "image": "https://images.unsplash.com/photo-1496062031256-47a19d866f85?w=500",
      "category": "Regalos",
      "subcategory": ""
    },
    {
      "name": "Set de Caligrafía Tradicional",
      "description": "Pluma estilográfica antigua de pluma real, tinteros y puntas intercambiables en caja de regalo.",
      "price": 450.0,
      "image": "https://images.unsplash.com/photo-1516962215378-7fa2e137ae93?w=500",
      "category": "Regalos",
      "subcategory": ""
    },
    {
      "name": "Kit de Cerveza Artesanal Casera",
      "description": "Contiene todo lo necesario para fermentar y embotellar tus propias cervezas rubias en casa.",
      "price": 899.0,
      "image": "https://images.unsplash.com/photo-1566633806327-68e152aaf26d?w=500",
      "category": "Regalos",
      "subcategory": ""
    },
    {
      "name": "Llavero de Proyección Personalizado",
      "description": "Llavero de plata esterlina que proyecta una foto familiar al iluminarlo con el celular.",
      "price": 199.0,
      "image": "https://images.unsplash.com/photo-1582139329536-e7284fece509?w=500",
      "category": "Regalos",
      "subcategory": ""
    },

    // 3. OFERTAS (10)
    {
      "name": "Audífonos Bluetooth Deportivos",
      "description": "Super oferta: Cancelación de ruido activa, 20 horas de batería continua y sonido estéreo.",
      "price": 349.0,
      "image": "https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=500",
      "category": "Ofertas",
      "subcategory": ""
    },
    {
      "name": "Cargador Portátil Powerbank 20k mAh",
      "description": "Carga rápida multidispositivo de 20,000mAh para celulares y tabletas a mitad de precio.",
      "price": 289.0,
      "image": "https://images.unsplash.com/photo-1609592424109-dd8e3d081f9a?w=500",
      "category": "Ofertas",
      "subcategory": ""
    },
    {
      "name": "Humidificador Ultrasónico LED",
      "description": "Humidifica tus espacios y aromatiza con aceites esenciales, luces de colores relajantes.",
      "price": 180.0,
      "image": "https://images.unsplash.com/photo-1615485290382-441e4d049cb5?w=500",
      "category": "Ofertas",
      "subcategory": ""
    },
    {
      "name": "Cámara de Seguridad WiFi 360",
      "description": "Vigilancia en tiempo real 1080P FHD, audio bidireccional y visión nocturna inteligente.",
      "price": 450.0,
      "image": "https://images.unsplash.com/photo-1557862921-37829c790f19?w=500",
      "category": "Ofertas",
      "subcategory": ""
    },
    {
      "name": "Bocina Bluetooth Impermeable IPX7",
      "description": "Ideal para llevar a la alberca, gran fidelidad de bajos y 12 horas de reproducción.",
      "price": 399.0,
      "image": "https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=500",
      "category": "Ofertas",
      "subcategory": ""
    },
    {
      "name": "Kit de Destornilladores de Precisión",
      "description": "Set de 115 piezas en estuche portátil para reparaciones de celulares y laptops.",
      "price": 210.0,
      "image": "https://images.unsplash.com/photo-1581166397057-235af2b7c909?w=500",
      "category": "Ofertas",
      "subcategory": ""
    },
    {
      "name": "Soporte de Celular para Auto MagSafe",
      "description": "Fijación magnética potente para ventilas de automóvil, carga inalámbrica compatible.",
      "price": 150.0,
      "image": "https://images.unsplash.com/photo-1586105251261-72a756497a11?w=500",
      "category": "Ofertas",
      "subcategory": ""
    },
    {
      "name": "Afeitadora Eléctrica Recargable",
      "description": "Afeitado seco y húmedo súper al ras, cuchillas autoafilables de acero quirúrgico.",
      "price": 380.0,
      "image": "https://images.unsplash.com/photo-1621607512214-68297480165e?w=500",
      "category": "Ofertas",
      "subcategory": ""
    },
    {
      "name": "Lámpara de Escritorio LED Táctil",
      "description": "Brazo flexible, 3 niveles de brillo inteligente y cargador inalámbrico incorporado.",
      "price": 299.0,
      "image": "https://images.unsplash.com/photo-1507473885765-e6ed057f782c?w=500",
      "category": "Ofertas",
      "subcategory": ""
    },
    {
      "name": "Termo de Acero Inoxidable 1 Litro",
      "description": "Conserva líquidos fríos por 24 horas y calientes por 12 horas, libre de BPA.",
      "price": 199.0,
      "image": "https://images.unsplash.com/photo-1602143407151-7111542de6e8?w=500",
      "category": "Ofertas",
      "subcategory": ""
    },

    // 4. SUPER Y CONVIVENCIA (10)
    {
      "name": "Café en Grano Veracruz Orgánico",
      "description": "Café de altura tostado medio, 100% arábica artesanal con notas cítricas y dulces.",
      "price": 180.0,
      "image": "https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=500",
      "category": "Super y convivencia",
      "subcategory": ""
    },
    {
      "name": "Caja de Barras de Avena Integral (12u)",
      "description": "Snacks saludables con chispas de chocolate y miel de abeja orgánica.",
      "price": 89.0,
      "image": "https://images.unsplash.com/photo-1568254183919-78a4f43a2877?w=500",
      "category": "Super y convivencia",
      "subcategory": ""
    },
    {
      "name": "Paquete de Papel Higiénico 32 Rollos",
      "description": "Papel higiénico premium súper acolchado de triple hoja, máxima suavidad y duración.",
      "price": 199.0,
      "image": "https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=500",
      "category": "Super y convivencia",
      "subcategory": ""
    },
    {
      "name": "Detergente Líquido Multiusos 5 Litros",
      "description": "Remueve manchas difíciles y cuida el color de tus prendas desde la primera lavada.",
      "price": 149.0,
      "image": "https://images.unsplash.com/photo-1610557892470-76d74cd120a1?w=500",
      "category": "Super y convivencia",
      "subcategory": ""
    },
    {
      "name": "Aceite de Oliva Extra Virgen 750ml",
      "description": "Aceite español prensado en frío de gran pureza para ensaladas y cocina saludable.",
      "price": 220.0,
      "image": "https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=500",
      "category": "Super y convivencia",
      "subcategory": ""
    },
    {
      "name": "Pack de Agua Mineral de Manantial (12u)",
      "description": "Agua mineral gasificada refrescante ideal para comidas familiares.",
      "price": 110.0,
      "image": "https://images.unsplash.com/photo-1548839130-3bfac07ce8af?w=500",
      "category": "Super y convivencia",
      "subcategory": ""
    },
    {
      "name": "Cereal de Trigo y Frutos Rojos 500g",
      "description": "Alto en fibra y fortificado con vitaminas esenciales para un desayuno energético.",
      "price": 65.0,
      "image": "https://images.unsplash.com/photo-1521483451539-c97b30c3e43a?w=500",
      "category": "Super y convivencia",
      "subcategory": ""
    },
    {
      "name": "Té Verde Matcha Puro Organico 100g",
      "description": "Polvo de té matcha ceremonial importado directamente de Japón.",
      "price": 289.0,
      "image": "https://images.unsplash.com/photo-1536256263959-770b48d82b0a?w=500",
      "category": "Super y convivencia",
      "subcategory": ""
    },
    {
      "name": "Papas Fritas Botaneras Sal de Mar (Set)",
      "description": "Tres bolsas de papas crujientes ideales para ver partidos o reuniones.",
      "price": 95.0,
      "image": "https://images.unsplash.com/photo-1566478989037-eec170784d0b?w=500",
      "category": "Super y convivencia",
      "subcategory": ""
    },
    {
      "name": "Vino Tinto Malbec Mendoza 750ml",
      "description": "Vino tinto argentino de gran cuerpo, ideal para maridar con carnes rojas y pastas.",
      "price": 259.0,
      "image": "https://images.unsplash.com/photo-1510812431401-41d2bd2722f3?w=500",
      "category": "Super y convivencia",
      "subcategory": ""
    },

    // 5. FARMACIA Y CUIDADO PERSONAL (10)
    {
      "name": "Bloqueador Solar FPS 50+ 200ml",
      "description": "Protección solar de amplio espectro, toque seco ideal para todo tipo de piel.",
      "price": 310.0,
      "image": "https://images.unsplash.com/photo-1556228720-195a672e8a03?w=500",
      "category": "Farmacia y cuidado personal",
      "subcategory": ""
    },
    {
      "name": "Serum Facial Ácido Hialurónico",
      "description": "Hidratación profunda 24h, reduce líneas de expresión y regenera colágeno natural.",
      "price": 349.0,
      "image": "https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=500",
      "category": "Farmacia y cuidado personal",
      "subcategory": ""
    },
    {
      "name": "Cepillo Dental Eléctrico Recargable",
      "description": "Limpieza profesional con 3 modos de cepillado, incluye 2 cabezales de repuesto.",
      "price": 699.0,
      "image": "https://images.unsplash.com/photo-1559591937-e35271676f3c?w=500",
      "category": "Farmacia y cuidado personal",
      "subcategory": ""
    },
    {
      "name": "Shampoo de Biotina y Queratina",
      "description": "Previene la caída y fortalece el crecimiento capilar desde la raíz.",
      "price": 149.0,
      "image": "https://images.unsplash.com/photo-1535585209827-a15fcdbc4c2d?w=500",
      "category": "Farmacia y cuidado personal",
      "subcategory": ""
    },
    {
      "name": "Crema Corporal Hidratación Intensiva",
      "description": "Fórmula con manteca de karité, repara pieles extra secas de inmediato.",
      "price": 99.0,
      "image": "https://images.unsplash.com/photo-1601049541289-9b1b7bbbfe19?w=500",
      "category": "Farmacia y cuidado personal",
      "subcategory": ""
    },
    {
      "name": "Multivitamínico Diario (90 Cápsulas)",
      "description": "Contiene vitaminas A, C, D, E, Zinc y Hierro para fortalecer tus defensas.",
      "price": 279.0,
      "image": "https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=500",
      "category": "Farmacia y cuidado personal",
      "subcategory": ""
    },
    {
      "name": "Gel Desinfectante de Manos 1 Litro",
      "description": "Alcohol en gel al 70% antibacterial con aloe vera para evitar la resequedad.",
      "price": 85.0,
      "image": "https://images.unsplash.com/photo-1584483777733-eefe15104443?w=500",
      "category": "Farmacia y cuidado personal",
      "subcategory": ""
    },
    {
      "name": "Jabón Líquido Facial Purificante",
      "description": "Elimina el exceso de grasa y limpia los poros profundamente de impurezas.",
      "price": 180.0,
      "image": "https://images.unsplash.com/photo-1556229174-5e42a09e45af?w=500",
      "category": "Farmacia y cuidado personal",
      "subcategory": ""
    },
    {
      "name": "Pasta Dental Blanqueadora (Triple Pack)",
      "description": "Brinda protección anticaries y remueve manchas dentales de forma progresiva.",
      "price": 110.0,
      "image": "https://images.unsplash.com/photo-1559591937-c6a6e877e60b?w=500",
      "category": "Farmacia y cuidado personal",
      "subcategory": ""
    },
    {
      "name": "Kit de Aceites Esenciales Relajantes",
      "description": "Contiene 3 esencias puras: Lavanda, Eucalipto y Menta para aromaterapia.",
      "price": 199.0,
      "image": "https://images.unsplash.com/photo-1608571423902-eed4a5ad8108?w=500",
      "category": "Farmacia y cuidado personal",
      "subcategory": ""
    },

    // 6. MASCOTAS (10)
    {
      "name": "Alimento Premium Perro Adulto 15kg",
      "description": "Croquetas balanceadas altas en proteína para razas medianas y grandes.",
      "price": 999.0,
      "image": "https://images.unsplash.com/photo-1589924691106-07a2c633a677?w=500",
      "category": "Mascotas",
      "subcategory": ""
    },
    {
      "name": "Cama Ortopédica Relajante Mediana",
      "description": "Memory foam ultra suave, funda lavable de felpa para perros y gatos.",
      "price": 549.0,
      "image": "https://images.unsplash.com/photo-1541599540903-216a46ca1ad0?w=500",
      "category": "Mascotas",
      "subcategory": ""
    },
    {
      "name": "Rascador para Gatos Multinivel",
      "description": "Torre de juegos con postes de sisal, juguetes colgantes y casitas cómodas.",
      "price": 899.0,
      "image": "https://images.unsplash.com/photo-1545249390-6bdfa286032f?w=500",
      "category": "Mascotas",
      "subcategory": ""
    },
    {
      "name": "Juguete Dispensador de Premios KONG",
      "description": "Hule natural ultra resistente, ideal para rellenar con crema de maní o croquetas.",
      "price": 280.0,
      "image": "https://images.unsplash.com/photo-1576201836106-db1758fd1c97?w=500",
      "category": "Mascotas",
      "subcategory": ""
    },
    {
      "name": "Shampoo Antipulgas Orgánico 500ml",
      "description": "Fórmula biodegradable que limpia y protege el pelaje con extracto de lavanda.",
      "price": 149.0,
      "image": "https://images.unsplash.com/photo-1516734212186-a967f81ad0d7?w=500",
      "category": "Mascotas",
      "subcategory": ""
    },
    {
      "name": "Caja de Premios Dentales para Perro",
      "description": "Limpian los dientes, reducen sarro y refrescan el aliento de tu mascota.",
      "price": 199.0,
      "image": "https://images.unsplash.com/photo-1537151108122-244a20b7bb58?w=500",
      "category": "Mascotas",
      "subcategory": ""
    },
    {
      "name": "Bebedero Fuente Automático Gatos",
      "description": "Fuente eléctrica con triple filtro de carbón activo para agua fresca constante.",
      "price": 389.0,
      "image": "https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=500",
      "category": "Mascotas",
      "subcategory": ""
    },
    {
      "name": "Correa Retráctil de 5 Metros",
      "description": "Sistema de bloqueo rápido de un botón con cinta reflectante de alta resistencia.",
      "price": 185.0,
      "image": "https://images.unsplash.com/photo-1601758228041-f3b2795255f1?w=500",
      "category": "Mascotas",
      "subcategory": ""
    },
    {
      "name": "Plato de Alimentación Lenta Antiansiedad",
      "description": "Previene atragantamiento e indigestión obligando al perro a comer más despacio.",
      "price": 120.0,
      "image": "https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?w=500",
      "category": "Mascotas",
      "subcategory": ""
    },
    {
      "name": "Bolsas Biodegradables Desechos (120u)",
      "description": "Bolsas ecológicas resistentes, a prueba de fugas y con agradable aroma a lavanda.",
      "price": 99.0,
      "image": "https://images.unsplash.com/photo-1548199973-03cce0bbc87b?w=500",
      "category": "Mascotas",
      "subcategory": ""
    },

    // 7. MODA Y BELLEZA (10)
    {
      "name": "Paleta de Sombras Ojos Nude",
      "description": "18 tonos de alta pigmentación en acabados mate, satinados y con glitter.",
      "price": 350.0,
      "image": "https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=500",
      "category": "Moda y belleza",
      "subcategory": ""
    },
    {
      "name": "Labial Mate Indeleble Larga Duración",
      "description": "Color intenso mate que dura hasta 16 horas sin transferirse ni resecar.",
      "price": 189.0,
      "image": "https://images.unsplash.com/photo-1586495777744-4413f21062fa?w=500",
      "category": "Moda y belleza",
      "subcategory": ""
    },
    {
      "name": "Máscara de Pestañas Waterproof",
      "description": "Efecto pestañas postizas volumen extremo a prueba de agua.",
      "price": 149.0,
      "image": "https://images.unsplash.com/photo-1512496015851-a90fb38ba796?w=500",
      "category": "Moda y belleza",
      "subcategory": ""
    },
    {
      "name": "Perfume Mujer Floral 100ml",
      "description": "Fragancia fresca de jazmín, vainilla y notas amaderadas, ideal para el diario.",
      "price": 899.0,
      "image": "https://images.unsplash.com/photo-1541643600914-78b084683601?w=500",
      "category": "Moda y belleza",
      "subcategory": ""
    },
    {
      "name": "Plancha Alaciadora de Cabello Cerámica",
      "description": "Control de temperatura ajustable hasta 450F, tecnología anti-estática de iones.",
      "price": 649.0,
      "image": "https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=500",
      "category": "Moda y belleza",
      "subcategory": ""
    },
    {
      "name": "Kit de Brochas de Maquillaje (12u)",
      "description": "Cerdas sintéticas ultra suaves con mango de madera, estuche de cuero de regalo.",
      "price": 279.0,
      "image": "https://images.unsplash.com/photo-1522338258041-26c361c7786c?w=500",
      "category": "Moda y belleza",
      "subcategory": ""
    },
    {
      "name": "Base de Maquillaje Cobertura Total",
      "description": "Acabado mate natural, FPS 15, resistente al calor y sudor durante 24 horas.",
      "price": 299.0,
      "image": "https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=500",
      "category": "Moda y belleza",
      "subcategory": ""
    },
    {
      "name": "Kit de Esmaltes de Uñas en Gel (6u)",
      "description": "Colores de tendencia de larga duración, curado rápido con lámpara UV.",
      "price": 185.0,
      "image": "https://images.unsplash.com/photo-1604654894610-df63bc536371?w=500",
      "category": "Moda y belleza",
      "subcategory": ""
    },
    {
      "name": "Agua Micelar Limpiadora 400ml",
      "description": "Limpia, desmaquilla y tonifica rostro, ojos y labios de forma suave en un paso.",
      "price": 120.0,
      "image": "https://images.unsplash.com/photo-1616683693504-3ea7e9ad6fec?w=500",
      "category": "Moda y belleza",
      "subcategory": ""
    },
    {
      "name": "Mascarillas Faciales Hidratantes (10u)",
      "description": "Set de mascarillas de tela impregnadas de colágeno, té verde y aloe vera.",
      "price": 149.0,
      "image": "https://images.unsplash.com/photo-1512290923902-8a9f81dc236c?w=500",
      "category": "Moda y belleza",
      "subcategory": ""
    },

    // 8. HOGAR Y DIY (10)
    {
      "name": "Kit de Taladro Inalámbrico 20V",
      "description": "Incluye batería de litio, cargador rápido, puntas y brocas en maletín de plástico.",
      "price": 1299.0,
      "image": "https://images.unsplash.com/photo-1504148455328-c376907d081c?w=500",
      "category": "Hogar y diy",
      "subcategory": ""
    },
    {
      "name": "Organizador de Cocina Especiero",
      "description": "Soporte magnético giratorio con 12 frascos de vidrio para almacenar especias de cocina.",
      "price": 320.0,
      "image": "https://images.unsplash.com/photo-1556911220-e15b29be8c8f?w=500",
      "category": "Hogar y diy",
      "subcategory": ""
    },
    {
      "name": "Set de Caja de Herramientas (82 Piezas)",
      "description": "Contiene pinzas, llaves, martillo, flexómetro y destornilladores esenciales.",
      "price": 549.0,
      "image": "https://images.unsplash.com/photo-1530124566582-a618bc2615dc?w=500",
      "category": "Hogar y diy",
      "subcategory": ""
    },
    {
      "name": "Juego de Sábanas de Algodón Matrimonial",
      "description": "Sábanas ultra suaves, frescas, transpirables y resistentes a arrugas.",
      "price": 399.0,
      "image": "https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=500",
      "category": "Hogar y diy",
      "subcategory": ""
    },
    {
      "name": "Juego de Cuchillos de Cocina (6 Piezas)",
      "description": "Cuchillos de acero inoxidable con recubrimiento antiadherente negro mate y base elegante.",
      "price": 450.0,
      "image": "https://images.unsplash.com/photo-1593113598332-cd288d649433?w=500",
      "category": "Hogar y diy",
      "subcategory": ""
    },
    {
      "name": "Tiras de Luces LED RGB 10 Metros",
      "description": "Luces inteligentes con control remoto y control por app para decorar habitaciones.",
      "price": 289.0,
      "image": "https://images.unsplash.com/photo-1565814329452-e1efa11c5b89?w=500",
      "category": "Hogar y diy",
      "subcategory": ""
    },
    {
      "name": "Cajas Organizadoras de Plástico (Set de 3)",
      "description": "Contenedores transparentes con tapas herméticas y ruedas para almacenamiento bajo cama.",
      "price": 299.0,
      "image": "https://images.unsplash.com/photo-1595428774223-ef52624120d2?w=500",
      "category": "Hogar y diy",
      "subcategory": ""
    },
    {
      "name": "Cortinas Blackout Aislantes Térmicas",
      "description": "Bloquean 99% de luz exterior e aíslan ruido, juego de 2 paneles modernos.",
      "price": 380.0,
      "image": "https://images.unsplash.com/photo-1513694203232-719a280e022f?w=500",
      "category": "Hogar y diy",
      "subcategory": ""
    },
    {
      "name": "Pistola de Silicona Caliente + 30 Barras",
      "description": "Herramienta ideal para manualidades escolares, DIY y reparaciones rápidas.",
      "price": 149.0,
      "image": "https://images.unsplash.com/photo-1581166397057-235af2b7c909?w=500",
      "category": "Hogar y diy",
      "subcategory": ""
    },
    {
      "name": "Kit de Pintura Acrílica (24 Colores)",
      "description": "Tubos de pintura acrílica de alta calidad más set de 3 pinceles profesionales.",
      "price": 199.0,
      "image": "https://images.unsplash.com/photo-1513364776144-60967b0f800f?w=500",
      "category": "Hogar y diy",
      "subcategory": ""
    },

    // 9. MÚSICA (10)
    {
      "name": "Guitarra Acústica Clásica",
      "description": "Guitarra clásica de madera natural, incluye funda de transporte, afinador y plumillas.",
      "price": 1499.0,
      "image": "https://images.unsplash.com/photo-1510915361894-db8b60106cb1?w=500",
      "category": "Música",
      "subcategory": ""
    },
    {
      "name": "Teclado Musical Electrónico 61 Teclas",
      "description": "Piano con 300 tonos, soporte de partituras, audífonos y micrófono integrados.",
      "price": 1899.0,
      "image": "https://images.unsplash.com/photo-1552422535-c45813c61732?w=500",
      "category": "Música",
      "subcategory": ""
    },
    {
      "name": "Ukelele Soprano de Madera",
      "description": "Excelente para principiantes, cuerpo de caoba de sonido dulce, cuerdas Aquila.",
      "price": 499.0,
      "image": "https://images.unsplash.com/photo-1507838153414-b4b713384a76?w=500",
      "category": "Música",
      "subcategory": ""
    },
    {
      "name": "Amplificador de Guitarra 15W",
      "description": "Portátil y potente, ecualizador de 3 bandas con distorsión overdrive integrada.",
      "price": 899.0,
      "image": "https://images.unsplash.com/photo-1598653222000-6b7b7a552625?w=500",
      "category": "Música",
      "subcategory": ""
    },
    {
      "name": "Micrófono Dinámico Vocal",
      "description": "Ideal para karaoke, presentaciones en vivo o grabaciones con cable de 3 metros XLR.",
      "price": 280.0,
      "image": "https://images.unsplash.com/photo-1590602847861-f357a9332bbc?w=500",
      "category": "Música",
      "subcategory": ""
    },
    {
      "name": "Pedal de Efectos Delay Analógico",
      "description": "Carcasa de metal resistente con bypass real para guitarristas profesionales.",
      "price": 549.0,
      "image": "https://images.unsplash.com/photo-1598488035139-bdbb2231ce04?w=500",
      "category": "Música",
      "subcategory": ""
    },
    {
      "name": "Afinador de Pinza Digital Cromático",
      "description": "Pantalla retroiluminada de alta precisión para guitarra, bajo, ukelele y violín.",
      "price": 120.0,
      "image": "https://images.unsplash.com/photo-1605020482762-689064835822?w=500",
      "category": "Música",
      "subcategory": ""
    },
    {
      "name": "Soporte Universal de Guitarra",
      "description": "Soporte de piso acolchado, plegable y seguro para evitar caídas o rayones.",
      "price": 149.0,
      "image": "https://images.unsplash.com/photo-1510915361894-db8b60106cb1?w=500",
      "category": "Música",
      "subcategory": ""
    },
    {
      "name": "Atril para Partituras Plegable",
      "description": "Atril de metal de altura ajustable con bolsa resistente para transporte.",
      "price": 199.0,
      "image": "https://images.unsplash.com/photo-1507838153414-b4b713384a76?w=500",
      "category": "Música",
      "subcategory": ""
    },
    {
      "name": "Set de Plumillas de Guitarra (24u)",
      "description": "Grosor surtido con porta plumillas magnético de cuero elegante.",
      "price": 85.0,
      "image": "https://images.unsplash.com/photo-1605020482762-689064835822?w=500",
      "category": "Música",
      "subcategory": ""
    },

    // 10. VIDEO Y GAMING (10)
    {
      "name": "Control Inalámbrico Xbox Serie X/S",
      "description": "Diseño ergonómico texturizado, conectividad Bluetooth oficial para consola y PC.",
      "price": 1299.0,
      "image": "https://images.unsplash.com/photo-1580234810907-b40315b76418?w=500",
      "category": "Video y gaming",
      "subcategory": ""
    },
    {
      "name": "Audífonos Gaming RGB con Micrófono",
      "description": "Sonido envolvente 7.1 envolvente, diadema acolchada cómoda de largas jornadas.",
      "price": 499.0,
      "image": "https://images.unsplash.com/photo-1618384887929-16ec33fab9ef?w=500",
      "category": "Video y gaming",
      "subcategory": ""
    },
    {
      "name": "Teclado Mecánico Switch Azul Gamer",
      "description": "Retroiluminación LED arcoíris, teclas 100% anti-ghosting ideales para eSports.",
      "price": 699.0,
      "image": "https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=500",
      "category": "Video y gaming",
      "subcategory": ""
    },
    {
      "name": "Mouse Gamer Programable 7200 DPI",
      "description": "Pesos ajustables, botones laterales e iluminación RGB sincronizada.",
      "price": 289.0,
      "image": "https://images.unsplash.com/photo-1615663245857-ac93bb7c39e7?w=500",
      "category": "Video y gaming",
      "subcategory": ""
    },
    {
      "name": "Silla Gamer Ergonómica Premium",
      "description": "Soporte lumbar regulable, cojín cervical, reclinable 150 grados para reposo.",
      "price": 2499.0,
      "image": "https://images.unsplash.com/photo-1598550476439-6847785fce6e?w=500",
      "category": "Video y gaming",
      "subcategory": ""
    },
    {
      "name": "Tapete Escritorio XXL Antideslizante",
      "description": "Bordes cosidos reforzados de microfibra, tamaño gigante de 90x40cm.",
      "price": 199.0,
      "image": "https://images.unsplash.com/photo-1585776245991-cf89dd7fc73a?w=500",
      "category": "Video y gaming",
      "subcategory": ""
    },
    {
      "name": "Cámara Web Full HD 1080P Stream",
      "description": "Ideal para transmisiones en vivo en Twitch/YouTube con micrófono dual integrado.",
      "price": 450.0,
      "image": "https://images.unsplash.com/photo-1612444530582-fc66183b16f7?w=500",
      "category": "Video y gaming",
      "subcategory": ""
    },
    {
      "name": "Aro de Luz LED para Gaming/Tik Tok",
      "description": "Incluye trípode extensible, 3 modos de luz y soporte para teléfono flexible.",
      "price": 249.0,
      "image": "https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=500",
      "category": "Video y gaming",
      "subcategory": ""
    },
    {
      "name": "Tarjeta de Captura de Video HDMI",
      "description": "Graba y transmite partidas de Consolas a PC a 1080P a 60 FPS sin latencia.",
      "price": 320.0,
      "image": "https://images.unsplash.com/photo-1542751371-adc38448a05e?w=500",
      "category": "Video y gaming",
      "subcategory": ""
    },
    {
      "name": "Soporte de Diadema Gaming para Escritorio",
      "description": "Soporte organizador de audífonos con 3 puertos de carga USB hub integrados.",
      "price": 279.0,
      "image": "https://images.unsplash.com/photo-1618384887929-16ec33fab9ef?w=500",
      "category": "Video y gaming",
      "subcategory": ""
    },

    // 11. ELECTRÓNICA (10)
    {
      "name": "Smart TV LED 4K UHD 43 Pulgadas",
      "description": "Pantalla Smart TV con Android TV integrado, Dolby Vision, accesos directos de voz.",
      "price": 5499.0,
      "image": "https://images.unsplash.com/photo-1593305841991-05c297ba4575?w=500",
      "category": "Electrónica",
      "subcategory": ""
    },
    {
      "name": "Smartphone FHD+ 128GB ROM",
      "description": "Pantalla de 90Hz, cámara triple de 50MP y batería inteligente de 5000mAh.",
      "price": 3299.0,
      "image": "https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=500",
      "category": "Electrónica",
      "subcategory": ""
    },
    {
      "name": "Tablet Android 10 Pulgadas",
      "description": "Perfecta para clases en línea y entretenimiento con memoria RAM de 4GB.",
      "price": 2499.0,
      "image": "https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=500",
      "category": "Electrónica",
      "subcategory": ""
    },
    {
      "name": "Laptop de Oficina Celeron 8GB RAM",
      "description": "Disco de estado sólido SSD de 256GB, pantalla de 14.1 pulgadas FHD, ultra delgada.",
      "price": 6499.0,
      "image": "https://images.unsplash.com/photo-1496181130204-7552cc14b1e0?w=500",
      "category": "Electrónica",
      "subcategory": ""
    },
    {
      "name": "Proyector de Cine en Casa HD",
      "description": "Soporta resolución 1080p, parlantes incorporados, conectividad para celular y consolas.",
      "price": 1599.0,
      "image": "https://images.unsplash.com/photo-1535016120720-40c646be5580?w=500",
      "category": "Electrónica",
      "subcategory": ""
    },
    {
      "name": "Asistente Virtual Altavoz Inteligente",
      "description": "Controla tus luces, alarmas, música y dudas mediante comandos de voz.",
      "price": 649.0,
      "image": "https://images.unsplash.com/photo-1543512214-318c7553f230?w=500",
      "category": "Electrónica",
      "subcategory": ""
    },
    {
      "name": "Báscula Digital de Grasa Corporal",
      "description": "Conectividad Bluetooth, mide 13 métricas corporales mediante app móvil.",
      "price": 349.0,
      "image": "https://images.unsplash.com/photo-1574269909862-7e1d70bb8078?w=500",
      "category": "Electrónica",
      "subcategory": ""
    },
    {
      "name": "Disparador Remoto de Cámara Bluetooth",
      "description": "Mini control inalámbrico tipo botón para selfies y fotos grupales con trípode.",
      "price": 99.0,
      "image": "https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=500",
      "category": "Electrónica",
      "subcategory": ""
    },
    {
      "name": "Repetidor WiFi de Larga Distancia",
      "description": "Amplifica la cobertura de internet en tu hogar hasta 300 Mbps, fácil instalación.",
      "price": 280.0,
      "image": "https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=500",
      "category": "Electrónica",
      "subcategory": ""
    },
    {
      "name": "Smartwatch Reloj Inteligente AMOLED",
      "description": "Pantalla siempre encendida, sensor SpO2, medición de estrés y 100 modos deportivos.",
      "price": 1499.0,
      "image": "https://images.unsplash.com/photo-1508685096489-7aacd43bd3b1?w=500",
      "category": "Electrónica",
      "subcategory": ""
    },

    // 12. LIBROS Y LECTURA (10)
    {
      "name": "El Psicoanalista - John Katzenbach",
      "description": "Libro de suspenso psicológico impactante, un clásico de intriga criminal en edición especial.",
      "price": 289.0,
      "image": "https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=500",
      "category": "Libros y lectura",
      "subcategory": ""
    },
    {
      "name": "Hábitos Atómicos - James Clear",
      "description": "Método sencillo y probado para desarrollar hábitos positivos y eliminar los negativos.",
      "price": 299.0,
      "image": "https://images.unsplash.com/photo-1589829085413-56de8ae18c73?w=500",
      "category": "Libros y lectura",
      "subcategory": ""
    },
    {
      "name": "Cien Años de Soledad - Gabriel García Márquez",
      "description": "Obra cumbre del realismo mágico latinoamericano en hermosa pasta blanda.",
      "price": 249.0,
      "image": "https://images.unsplash.com/photo-1543002588-bfa74002ed7e?w=500",
      "category": "Libros y lectura",
      "subcategory": ""
    },
    {
      "name": "El Principito - Antoine de Saint-Exupéry",
      "description": "Edición ilustrada original de este clásico de la literatura filosófica universal.",
      "price": 120.0,
      "image": "https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=500",
      "category": "Libros y lectura",
      "subcategory": ""
    },
    {
      "name": "Padre Rico, Padre Pobre - Robert Kiyosaki",
      "description": "Guía básica de finanzas personales que cambiará tu forma de ver el dinero.",
      "price": 199.0,
      "image": "https://images.unsplash.com/photo-1592496431122-2349e0fbc666?w=500",
      "category": "Libros y lectura",
      "subcategory": ""
    },
    {
      "name": "Harry Potter y la Piedra Filosofal",
      "description": "El inicio de la saga mágica más famosa del mundo en hermosa edición rústica.",
      "price": 250.0,
      "image": "https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=500",
      "category": "Libros y lectura",
      "subcategory": ""
    },
    {
      "name": "El Hobbit - J.R.R. Tolkien",
      "description": "La novela de fantasía heroica que sirve de preludio al Señor de los Anillos.",
      "price": 320.0,
      "image": "https://images.unsplash.com/photo-1629992101753-56c196ec2baa?w=500",
      "category": "Libros y lectura",
      "subcategory": ""
    },
    {
      "name": "Sapiens: De Animales a Dioses",
      "description": "Una breve e inteligente historia de la humanidad por Yuval Noah Harari.",
      "price": 349.0,
      "image": "https://images.unsplash.com/photo-1589829085413-56de8ae18c73?w=500",
      "category": "Libros y lectura",
      "subcategory": ""
    },
    {
      "name": "Lámpara de Lectura para Cuello LED",
      "description": "Brazos flexibles con luz regulable, ideal para leer de noche sin molestar a nadie.",
      "price": 185.0,
      "image": "https://images.unsplash.com/photo-1507473885765-e6ed057f782c?w=500",
      "category": "Libros y lectura",
      "subcategory": ""
    },
    {
      "name": "Lupa de Lectura con Luz LED",
      "description": "Lente de gran aumento rectangular perfecta para lectura de libros de letra pequeña.",
      "price": 149.0,
      "image": "https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=500",
      "category": "Libros y lectura",
      "subcategory": ""
    },

    // 13. JUGUETES Y BEBES (10)
    {
      "name": "Bloques de Construcción LEGO Classic",
      "description": "Caja de ladrillos creativos con 790 piezas multicolores para construir sin límites.",
      "price": 799.0,
      "image": "https://images.unsplash.com/photo-1587654780291-39c9404d746b?w=500",
      "category": "Juguetes y bebes",
      "subcategory": ""
    },
    {
      "name": "Gimnasio de Actividades para Bebés",
      "description": "Tapete acolchado con juguetes colgantes, luces y piano de patadas musical.",
      "price": 549.0,
      "image": "https://images.unsplash.com/photo-1515488042361-404e9250afef?w=500",
      "category": "Juguetes y bebes",
      "subcategory": ""
    },
    {
      "name": "Coche de Juguete de Control Remoto",
      "description": "Todoterreno 4x4 todo terreno de alta velocidad con batería recargable por USB.",
      "price": 389.0,
      "image": "https://images.unsplash.com/photo-1596461404969-9ae70f2830c1?w=500",
      "category": "Juguetes y bebes",
      "subcategory": ""
    },
    {
      "name": "Set de Sonajeras y Mordederas (Set)",
      "description": "Contiene 8 sonajas de plástico suave libre de BPA para aliviar las encías del bebé.",
      "price": 199.0,
      "image": "https://images.unsplash.com/photo-1515488042361-404e9250afef?w=500",
      "category": "Juguetes y bebes",
      "subcategory": ""
    },
    {
      "name": "Muñeca de Moda Articulada",
      "description": "Incluye múltiples cambios de ropa modernos, accesorios elegantes y cepillo de cabello.",
      "price": 350.0,
      "image": "https://images.unsplash.com/photo-1559251606-c623743a6d76?w=500",
      "category": "Juguetes y bebes",
      "subcategory": ""
    },
    {
      "name": "Juego de Mesa Turista Mundial",
      "description": "Clásico juego de mesa familiar para comprar países, construir hoteles y competir.",
      "price": 249.0,
      "image": "https://images.unsplash.com/photo-1610890716171-6b1bb98ffd09?w=500",
      "category": "Juguetes y bebes",
      "subcategory": ""
    },
    {
      "name": "Cuna Corral Portátil para Bebé",
      "description": "Plegado fácil de viaje con cambiador desmontable, mosquitero y bolsa de viaje.",
      "price": 1899.0,
      "image": "https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=500",
      "category": "Juguetes y bebes",
      "subcategory": ""
    },
    {
      "name": "Calentador de Biberones Eléctrico",
      "description": "Calienta leche y comida de bebé de forma uniforme en 3 minutos, función esterilizadora.",
      "price": 450.0,
      "image": "https://images.unsplash.com/photo-1596461404969-9ae70f2830c1?w=500",
      "category": "Juguetes y bebes",
      "subcategory": ""
    },
    {
      "name": "Bloques de Madera Educativos (50u)",
      "description": "Figuras geométricas de colores de madera natural para desarrollar la motricidad fina.",
      "price": 180.0,
      "image": "https://images.unsplash.com/photo-1515488042361-404e9250afef?w=500",
      "category": "Juguetes y bebes",
      "subcategory": ""
    },
    {
      "name": "Peluches Apilables de Texturas",
      "description": "Anillos de tela afelpada con sonidos de cascabel para estimulación temprana.",
      "price": 149.0,
      "image": "https://images.unsplash.com/photo-1559251606-c623743a6d76?w=500",
      "category": "Juguetes y bebes",
      "subcategory": ""
    },

    // 14. ROPA (10)
    // Hombre (3)
    {
      "name": "Chaqueta de Mezclilla Hombre",
      "description": "Chaqueta casual de corte regular, mezclilla resistente de alta calidad.",
      "price": 699.0,
      "image": "https://images.unsplash.com/photo-1576995853123-5a10305d93c0?w=500",
      "category": "Ropa",
      "subcategory": "Hombre"
    },
    {
      "name": "Playera Polo Slim Fit Caballero",
      "description": "Camisa polo de algodón suave, ideal para salidas casuales u oficina semiformal.",
      "price": 299.0,
      "image": "https://images.unsplash.com/photo-1581655353564-df123a1eb820?w=500",
      "category": "Ropa",
      "subcategory": "Hombre"
    },
    {
      "name": "Pantalón de Vestir Chino Beige",
      "description": "Pantalón cómodo tipo chino de corte recto con bolsillos funcionales.",
      "price": 489.0,
      "image": "https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?w=500",
      "category": "Ropa",
      "subcategory": "Hombre"
    },
    // Mujer (3)
    {
      "name": "Vestido Casual de Primavera Floral",
      "description": "Vestido de tela ligera con hermoso estampado floral y ajuste de cintura cómodo.",
      "price": 399.0,
      "image": "https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=500",
      "category": "Ropa",
      "subcategory": "Mujer"
    },
    {
      "name": "Suéter de Punto Ligero Femenino",
      "description": "Prenda de abrigo suave con cuello redondo, ideal para climas templados.",
      "price": 349.0,
      "image": "https://images.unsplash.com/photo-1614975058789-41316d0e2e9c?w=500",
      "category": "Ropa",
      "subcategory": "Mujer"
    },
    {
      "name": "Jeans Skinny de Tiro Alto Dama",
      "description": "Mezclilla elástica moldeadora de silueta, color azul clásico lavado.",
      "price": 450.0,
      "image": "https://images.unsplash.com/photo-1541099649105-f69ad21f3246?w=500",
      "category": "Ropa",
      "subcategory": "Mujer"
    },
    // Niños (2)
    {
      "name": "Sudadera Infantil con Capucha Dinosaurio",
      "description": "Divertido diseño de dinosaurio en la espalda, forro polar suave y abrigado.",
      "price": 289.0,
      "image": "https://images.unsplash.com/photo-1519457431-44ccd64a579b?w=500",
      "category": "Ropa",
      "subcategory": "Niños"
    },
    {
      "name": "Conjunto Deportivo Infantil (Pants + Playera)",
      "description": "Algodón ultra cómodo, ideal para juego libre y actividades escolares.",
      "price": 349.0,
      "image": "https://images.unsplash.com/photo-1519457431-44ccd64a579b?w=500",
      "category": "Ropa",
      "subcategory": "Niños"
    },
    // Niñas (2)
    {
      "name": "Vestido Infantil de Tul Rosado",
      "description": "Perfecto para fiestas, falda de tul esponjoso con detalles brillantes de estrellas.",
      "price": 350.0,
      "image": "https://images.unsplash.com/photo-1503919545889-aef636e10ad4?w=500",
      "category": "Ropa",
      "subcategory": "Niñas"
    },
    {
      "name": "Mameluco Pijama Unicornio con Cierre",
      "description": "Tela afelpada tipo polar, capucha con cuerno y detalles bordados tiernos.",
      "price": 259.0,
      "image": "https://images.unsplash.com/photo-1503919545889-aef636e10ad4?w=500",
      "category": "Ropa",
      "subcategory": "Niñas"
    }
  ];
}
