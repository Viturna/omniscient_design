/** @type {import('tailwindcss').Config} */
module.exports = {

    content: [
        './app/views/**/*.erb',
        './app/helpers/**/*.rb',
        './app/assets/stylesheets/**/*.css',
        './app/javascript/**/*.js'
    ],
    theme: {
        extend: {
            colors: {
                primary: "#202020",
                secondary: "#fff",
                background: "#F7f7F7",
            },
        },
    },
    plugins: [],
}
