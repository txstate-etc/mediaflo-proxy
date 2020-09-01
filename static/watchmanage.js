document.addEventListener('DOMContentLoaded', function () {
  const table = document.getElementById('ctl00_pageContents_ctl00_mediaDataGrid')
  let reloadtimer
  if (!table) return
  const observer = new MutationObserver(function (mutationList) {
    for (const mutation of mutationList) {
      if (
        (mutation.type === 'characterData' && mutation.target.data === '0') ||
        (mutation.type === 'childList' && mutation.target.textContent === '0')
      ) {
        clearTimeout(reloadtimer)
        reloadtimer = setTimeout(function () {
          document.location.reload()
        }, 100)
      }
    }
  })
  const cells = table.querySelectorAll('td:first-child')
  for (const cell of cells) {
    observer.observe(table, { subtree: true, childList: true, characterData: true })
  }
})
