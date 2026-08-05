module.exports = {
  plugins: [
    require('@fullhuman/postcss-purgecss')({
      content: [
        './app/views/**/*.html.erb',
        './app/helpers/**/*.rb',
        './app/javascript/**/*.js',
        './app/components/**/*.html.erb',
        './app/components/**/*.rb'
      ],
      safelist: [/lenis/],
      defaultExtractor: content => content.match(/[A-Za-z0-9-_:/]+/g) || []
    })
  ]
}
