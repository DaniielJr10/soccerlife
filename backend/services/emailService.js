const nodemailer = require('nodemailer');

// Configuración del transportador de email
const createTransporter = async () => {
  // Usar Gmail para envío real
  return nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: process.env.EMAIL_USER,
      pass: process.env.EMAIL_PASS
    }
  });
};

// Función para enviar email de recuperación de contraseña
const enviarEmailRecuperacion = async (email, codigo) => {
  try {
    const transporter = await createTransporter();
    
    const mailOptions = {
      from: `"⚽ Soccer Life" <${process.env.EMAIL_USER}>`,
      to: email,
      subject: '⚽ Soccer Life - Código de Recuperación de Contraseña',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; background-color: #f5f5f5;">
          <div style="background: linear-gradient(135deg, #00b4db, #0083b0); padding: 30px; border-radius: 10px; text-align: center;">
            <h1 style="color: white; margin: 0; font-size: 28px;">⚽ Soccer Life</h1>
            <p style="color: white; margin: 10px 0 0 0; font-size: 16px;">Recuperación de Contraseña</p>
          </div>
          
          <div style="background: white; padding: 30px; border-radius: 10px; margin-top: 20px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">
            <h2 style="color: #333; margin-bottom: 20px;">Código de Verificación</h2>
            <p style="color: #666; font-size: 16px; line-height: 1.5;">
              Hemos recibido una solicitud para restablecer la contraseña de tu cuenta en Soccer Life.
            </p>
            
            <div style="text-align: center; margin: 30px 0;">
              <div style="background: linear-gradient(135deg, #00b4db, #0083b0); color: white; font-size: 32px; font-weight: bold; padding: 20px; border-radius: 10px; letter-spacing: 8px; display: inline-block;">
                ${codigo}
              </div>
            </div>
            
            <p style="color: #666; font-size: 14px; line-height: 1.5;">
              • Este código expira en <strong>15 minutos</strong><br>
              • Solo puedes usarlo una vez<br>
              • Si no solicitaste este cambio, ignora este email
            </p>
            
            <div style="border-top: 1px solid #eee; margin-top: 30px; padding-top: 20px; text-align: center;">
              <p style="color: #999; font-size: 12px; margin: 0;">
                Este es un email automático, no respondas a este mensaje.
              </p>
            </div>
          </div>
        </div>
      `
    };

    const result = await transporter.sendMail(mailOptions);
    
    console.log('✅ Email enviado exitosamente a:', email);
    console.log('📧 Message ID:', result.messageId);
    return { success: true, messageId: result.messageId };
    
  } catch (error) {
    console.error('❌ Error enviando email:', error);
    return { success: false, error: error.message };
  }
};

module.exports = {
  enviarEmailRecuperacion
};
