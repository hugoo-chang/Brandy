# Brandy - Landing Page

Landing page profesional para el generador de nombres de marca Brandy.

## 🎨 Diseño

Inspirado en la plantilla **WordPress Carter**, con estética limpia, moderna y minimalista:
- Tipografía elegante (serif para títulos, sans-serif para cuerpo)
- Esquema de colores púrpura/índigo
- Diseño responsivo
- Animaciones suaves
- Sombras sutiles

## 📋 Estructura

### 1. **Hero Section**
- Título principal
- Descripción del servicio
- Características destacadas
- Llamada a la acción visual

### 2. **Brief Form** (antes de precios)
Formulario completo de Brief Brandy con 10 preguntas:
1. Resumen del negocio (30 palabras)
2. Video sobre el origen del negocio
3. Público objetivo
4. Problema que resuelve
5. 3 competidores principales
6. Atributos concretos
7. Eslogan en 5 palabras
8. 3 palabras clave
9. 3 rasgos de personalidad (checkboxes)
10. Problemática global que resuelve

**Validación incluida:**
- Campos requeridos
- Límite de palabras
- Exactamente 3 rasgos de personalidad

### 3. **Pricing Section**
Tres planes de precios:

#### 📦 **Básico** - S/ 299
- 50 nombres generados
- Análisis de similitud fonética
- Verificación básica INDECOPI
- Reporte en PDF

#### ⭐ **Premium** - S/ 599 (MÁS POPULAR)
- 200 nombres generados
- Análisis completo
- Verificación completa INDECOPI
- Análisis de probabilidad de registro
- Verificación de dominios
- 1 consulta con experto

#### 💎 **Elite** - S/ 1,299
- 500 nombres generados
- Análisis exhaustivo multi-algoritmo
- Verificación exhaustiva INDECOPI
- 3 consultas con experto
- Soporte prioritario 24/7
- Revisiones ilimitadas por 30 días
- Estrategia de posicionamiento
- Análisis de competencia

### 4. **Footer**
- Enlaces de navegación
- Información de contacto
- Derechos de autor
- Disclaimer INDECOPI

## 🚀 Cómo usar

### Abrir en navegador

**Opción 1: Directamente**
```bash
# Abrir el archivo HTML en tu navegador
open landing/index.html
# o en Windows/Linux:
xdg-open landing/index.html
```

**Opción 2: Con servidor local (recomendado)**
```bash
# Con Python
cd landing
python3 -m http.server 8080

# Luego abrir: http://localhost:8080
```

**Opción 3: Con VS Code**
1. Instalar extensión "Live Server"
2. Click derecho en `index.html`
3. Seleccionar "Open with Live Server"

## ✨ Características

### Diseño Responsivo
✅ Desktop (1200px+)
✅ Tablet (768px - 1199px)
✅ Mobile (< 768px)

### Interactividad
✅ Navegación suave (smooth scroll)
✅ Header con efecto al hacer scroll
✅ Validación de formulario en tiempo real
✅ Límite de 3 rasgos de personalidad
✅ Animaciones de entrada (fade in)
✅ Hover effects en tarjetas

### Validaciones del Formulario
- Campos requeridos marcados
- Límite de 30 palabras en resumen
- Límite de 5 palabras en eslogan
- Exactamente 3 rasgos de personalidad
- Formato URL para video
- Alertas descriptivas

## 🎨 Paleta de Colores

```css
--primary-color: #2d3436    /* Negro carbón */
--secondary-color: #6c5ce7  /* Púrpura */
--accent-color: #fd79a8     /* Rosa */
--text-dark: #2d3436        /* Texto principal */
--text-light: #636e72       /* Texto secundario */
--bg-light: #f8f9fa         /* Fondo claro */
--success-color: #00b894    /* Verde éxito */
```

## 📝 Tipografía

- **Títulos**: Georgia, Times New Roman (serif)
- **Cuerpo**: System fonts (-apple-system, Segoe UI, Roboto...)
- **Pesos**: 400 (normal), 600 (semi-bold), 700 (bold)

## 🔧 Personalización

### Cambiar precios
Edita las secciones `.plan-price` en el HTML:
```html
<div class="plan-price">
    S/ 299
    <span>/ una vez</span>
</div>
```

### Cambiar características de planes
Edita las listas `.plan-features`:
```html
<ul class="plan-features">
    <li>Tu característica aquí</li>
    <li class="disabled">Característica no incluida</li>
</ul>
```

### Cambiar colores
Modifica las variables CSS en el `:root`:
```css
:root {
    --secondary-color: #tu-color-aqui;
}
```

## 🔗 Integración Backend

El formulario está listo para integración. Descomentar y configurar:

```javascript
// En el evento submit del formulario
fetch('/api/submit-brief', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(data)
})
.then(response => response.json())
.then(data => {
    console.log('Success:', data);
    // Redirigir a página de pago
});
```

## 📱 Responsive Breakpoints

- **Desktop**: 1200px+
- **Tablet**: 768px - 1199px
- **Mobile**: < 768px

## ✅ Checklist de Producción

Antes de publicar:

- [ ] Actualizar enlaces de redes sociales
- [ ] Configurar formulario backend
- [ ] Configurar pasarela de pago
- [ ] Añadir Google Analytics
- [ ] Optimizar imágenes
- [ ] Añadir favicon
- [ ] Configurar meta tags SEO
- [ ] Añadir Open Graph tags
- [ ] Probar en múltiples navegadores
- [ ] Probar en dispositivos reales
- [ ] Configurar SSL (HTTPS)
- [ ] Añadir política de privacidad
- [ ] Añadir términos y condiciones

## 🌐 Navegadores Soportados

✅ Chrome/Edge (últimas 2 versiones)
✅ Firefox (últimas 2 versiones)
✅ Safari (últimas 2 versiones)
✅ Opera (últimas 2 versiones)

## 📊 Performance

- HTML semántico
- CSS inline (single file)
- JavaScript vanilla (sin dependencias)
- Optimizado para Core Web Vitals
- Carga rápida (<2s)

## 🔒 Seguridad

Implementar antes de producción:
- Validación server-side
- Protección CSRF
- Sanitización de inputs
- Rate limiting
- Captcha en formulario

## 📞 Soporte

Para modificaciones o dudas:
- Email: contacto@brandy.pe
- Documentación: ver código inline comments

## 📄 Licencia

© 2025 Brandy - Todos los derechos reservados

---

**Diseñado con ❤️ para el mercado peruano** 🇵🇪
