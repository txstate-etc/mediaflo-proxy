document.addEventListener('DOMContentLoaded', function () {
  const input = document.getElementById('ctl00_pageContent_LoginControl_userNameInput') || document.getElementById('ctl00_MainContent_login_userNameInput')
  if (!input) return
  input.addEventListener('change', function (e) {
    const val = input.value
    const cleanval = val.trim().toLocaleLowerCase()
    if (val !== cleanval) input.value = cleanval
  })
})
