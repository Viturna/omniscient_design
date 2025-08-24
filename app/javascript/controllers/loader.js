document.addEventListener('turbo:before-render', () => {
  const loading = document.querySelector('#loading')
  const content = document.querySelector('#content')

  if (loading) loading.style.display = 'block'
  if (content) content.style.display = 'none'
})

document.addEventListener('turbo:load', () => {
  const loading = document.querySelector('#loading')
  const content = document.querySelector('#content')

  if (loading) loading.style.display = 'none'
  if (content) content.style.display = 'block'
})
