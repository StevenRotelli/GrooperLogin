// ==UserScript==
// @name       GrooperLogout
// @description Adds a Logout button to user-info dropdown.
// @match       *://*/Grooper/*
// @match       *://*.grooperdemo.com/*
// ==/UserScript==
//
(function () {
  "use strict";
  let buttonExist = false;
  const checkExistInterval = setInterval(() => {
    const userMenu = document.querySelector(
      "body div.top-nav > div > div.navgroup > div.navgroup > .DropButton",
    );
    if (userMenu && !buttonExist) {
      const userHeading = userMenu.querySelector(".user-info > .header");
      if (userHeading) {
        const button = document.createElement("button");
        const label = document.createElement("span");
        label.innerText = "Logout";
        button.textContent = "Logout";
        button.title = "Sign out of Grooper";
        label.setAttribute(
          "style",
          "float: right; margin-top: 8px; margin-right: 8px;",
        );
        button.setAttribute("style", "float: right; margin-top: 8px;");
        button.classList.add("text-button");
        button.classList.add("material-icons");
        button.id = "logout-button";
        userHeading.appendChild(button);
        userHeading.appendChild(label);
        buttonExist = true;
        button.addEventListener("click", () => {
          window.location.href = "login.aspx?logout=true";
        });
      }
    }
  }, 100);
})();
