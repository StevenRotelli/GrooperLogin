<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Login.aspx.cs"
Inherits="Login" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
  <head runat="server">
    <meta charset="UTF-8">
    <title>Login</title>
    <link href="~/favicon.ico" rel="icon" type="image/x-icon"/>
    <link href="~/Login.css" rel="stylesheet" />
    <style></style>
    <script>
      let layoutCookie = getCookie("Layout");

      if (layoutCookie) {
        let layoutSettings = JSON.parse(layoutCookie);

        if (layoutSettings.liteMode) {
          document.body.classList.add("light");
          document.body.classList.remove("dark");
        } else {
          document.body.classList.add("dark");
          document.body.classList.remove("light");
        }
      }
    </script>
  </head>

  <body class="">
    <div class="bg-image">
      <form id="form1" runat="server">
        <div style="width: 100%">
          <h2>
            <img class="logo" src="Content/Images/grooper_logo.png" /><span
              >Enterprise</span
            >
          </h2>

          <div class="username field">
            <asp:Label
              ID="UsernameLabel"
              runat="server"
              Text="Username:"
            ></asp:Label>
            <asp:TextBox
              ID="UsernameTextBox"
              runat="server"
              placeholder="Username"
            />
          </div>

          <div class="password field">
            <asp:Label
              ID="PasswordLabel"
              runat="server"
              Text="Password:"
            ></asp:Label>
            <asp:TextBox
              ID="PasswordTextBox"
              runat="server"
              TextMode="Password"
              placeholder="Password"
            />
          </div>

          <asp:Button
            class="button"
            ID="LoginButton"
            runat="server"
            Text="Log In"
            OnClick="LoginButton_Click"
          />

          <br /><br />

          <asp:Label
            class="error"
            ID="ErrorMessageLabel"
            runat="server"
            ForeColor="Red"
            Visible="false"
          ></asp:Label>
        </div>
      </form>
      <footer class="fixed-bottom" role="contentinfo">
        <div class="container mt-0">&copy Copyright 2024 Grooper. Powered by
         <a
            href="https://www.bisok.com"
            target="_blank"
            rel="external nofollow noopener"
            >BIS</a
          >
        </div>
      </footer>
    </div>
  </body>
</html>
