<%@ WebHandler Language="C#" Class="email" %>

using System;
using System.Web;
using System.Configuration;

public class email : IHttpHandler
{

    private String emailServer = ConfigurationManager.AppSettings["SMTPServer"];
    private Boolean emailServerSSL = true;
    private String mailTo = ConfigurationManager.AppSettings["EmailTo"];
    private String mailFrom = ConfigurationManager.AppSettings["EmailFrom"];
    private String mailBcc = ConfigurationManager.AppSettings["EmailBcc"];
    private String mailSubject = "The Alliance Network Contact Form";


    public void ProcessRequest(HttpContext context) {
        
        var json = new System.Web.Script.Serialization.JavaScriptSerializer();
        var retobj = new returnObject() { Success = true };
        var data = context.Request.Params;
            
        context.Response.ContentType = "application/json";
        var client = new System.Net.Mail.SmtpClient(emailServer);
        
        if (!String.IsNullOrEmpty(data["email2"])) { context.Response.Write(json.Serialize(retobj)); return; }
        if (data["antiSpam"] != "ValidUser") { context.Response.Write(json.Serialize(retobj));  return ; }

        try
        {            
            client.EnableSsl = emailServerSSL;
            
            var username = ConfigurationManager.AppSettings["EmailUsername"];
            var password = ConfigurationManager.AppSettings["EmailPassword"];
            
            client.Credentials = new System.Net.NetworkCredential(username, password);
            
            var message = new System.Net.Mail.MailMessage();
            
            message.To.Add(mailTo);
            message.Subject = mailSubject;
            message.From = new System.Net.Mail.MailAddress(mailFrom);
            
            if (String.IsNullOrEmpty(data["email"]))
            {
                throw new Exception("No email address supplied");
            }
            else
            {
                //message.CC.Add(data["email"]);
                
                //if (String.IsNullOrEmpty(data["name"]))
                //{
                //    message.From = new System.Net.Mail.MailAddress(data["email"]);
                //}
                //else
                //{
                //    message.From = new System.Net.Mail.MailAddress(data["email"], data["name"]);
                //}
            }

            if (String.IsNullOrEmpty(data["message"]))
            {
                throw new Exception("No message entered");
            }
            else
            {
                message.Body = "Message from " + data["name"] + " " + data["email"] +"\r\n\r\n" + data["message"];
                message.IsBodyHtml = false;
            }
            
            message.Bcc.Add(mailBcc);

            client.Send(message);
        }
        catch (Exception ex)
        {
            retobj.Success = false;
            retobj.Error = ex.Message;
            try
            {
                client.Send(mailFrom , mailBcc, "Alliance Network Error", ex.ToString());
            }
            catch (Exception)
            {
                
            }
        }
        
        context.Response.Write(json.Serialize(retobj));
        
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}

public class returnObject
{
    public Boolean Success { get; set; }
    public String Error { get; set; }
}
