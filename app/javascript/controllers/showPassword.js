$(document).ready(function() {
  $('.toggle-password').on('click', function() {
    const target = $(this).data('target');
    const $passwordField = $(target);
    const $showPasswordIcon = $(this).find('.show-password-icon');
    const $hidePasswordIcon = $(this).find('.hide-password-icon');

    if ($passwordField.attr('type') === 'password') {
      $passwordField.attr('type', 'text');
      $showPasswordIcon.hide();
      $hidePasswordIcon.show();
    } else {
      $passwordField.attr('type', 'password');
      $showPasswordIcon.show();
      $hidePasswordIcon.hide();
    }
  });
});
