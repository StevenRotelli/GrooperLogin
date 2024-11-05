using System;
using System.Web;
using System.Web.Services;
using System.Web.Script.Services;
using System.DirectoryServices.AccountManagement;
using System.Web.Security;
using Newtonsoft.Json;

public partial class Login : System.Web.UI.Page
{
    public string colorshceme = "dark";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Request.QueryString["logout"] == "true")
        {
            Logout();
        }
        Response.ContentEncoding = System.Text.Encoding.UTF8;
        if (Request.IsAuthenticated && User.Identity.IsAuthenticated)
        {
            
            HandleAuthenticatedUser();
            return;
        }

        if (!IsPostBack)
        {
            HttpCookie layoutCookie = Request.Cookies["Layout"];

            if (layoutCookie != null)
            {
                string cookieValue = layoutCookie.Value;
                var layoutSettings = JsonConvert.DeserializeObject<LayoutSettings>(cookieValue);

                if (layoutSettings.liteMode)
                {
                    colorshceme = "light";
                }
            }
            HttpCookie userNameCookie = Request.Cookies["lastUser"];
            if (userNameCookie != null) 
            {
                UsernameTextBox.Text = userNameCookie.Value;
            }
        }
    }

    private void HandleAuthenticatedUser()
    {
        HttpCookie layoutCookie = Request.Cookies["Layout"];

        if (layoutCookie != null)
        {
            var layoutSettings = JsonConvert.DeserializeObject<LayoutSettings>(layoutCookie.Value);

            if (layoutSettings.liteMode)
            {
                colorshceme = "light";
            }
        }
        else
        {
            colorshceme = "dark";
        }

        Response.Redirect("~");
    }

    public void Logout()
    {
        Session.Clear();
        Session.Abandon();

        if (Request.Cookies[".ASPXAUTH"] != null)
        {
            HttpCookie authCookie = new HttpCookie(".ASPXAUTH");
            authCookie.Expires = DateTime.Now.AddDays(-1d);  // Expire the cookie
            Response.Cookies.Add(authCookie);
        }

        Response.Redirect("Login.aspx");
    }
    protected void LoginButton_Click(object sender, EventArgs e)
    {
        string username = UsernameTextBox.Text;
        string password = PasswordTextBox.Text;
        bool isAuthenticated = false;

        try
        {
            using (PrincipalContext pc = new PrincipalContext(ContextType.Domain))
            {
                isAuthenticated = pc.ValidateCredentials(username, password);
            }

            if (isAuthenticated)
            {
                HttpCookie lastUserCookie = new HttpCookie("lastUser", username);
                lastUserCookie.Expires = DateTime.Now.AddDays(30);
                Response.Cookies.Add(lastUserCookie);
                FormsAuthentication.SetAuthCookie(username, false);

                HandleAuthenticatedUser();
            }
            else
            {
                ErrorMessageLabel.Text = "Invalid username or password. Please try again.";
                ErrorMessageLabel.Visible = true;
            }
        }
        catch (Exception ex)
        {
            ErrorMessageLabel.Text = ex.Message;
            ErrorMessageLabel.Visible = true;
        }
    }
}

public class LayoutSettings
{
    public bool liteMode { get; set; }
}
