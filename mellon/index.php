<?php

require 'vendor/autoload.php';
$loader = new \Twig\Loader\FilesystemLoader('templates');
$twig = new \Twig\Environment($loader, ['debug' => true]);
$twig->addExtension(new \Twig\Extension\DebugExtension());
$template = $twig->load('index.html.twig');
$attributes = [];
foreach ($_SERVER as $key => $value) {
    if (
        str_starts_with($key, 'MELLON_') &&
        !(
            str_starts_with($key, 'MELLON_NAME_ID')
            || str_starts_with($key, 'MELLON_ASSERTION_ID')
            || str_starts_with($key, 'MELLON_SESSION')
            || str_starts_with($key, 'MELLON_SAML_RESPONSE')
        )
    ) {
        $attributes[$key] = $value;
    }

    if (
        str_starts_with($key, 'MELLON_NAME_ID') ||
        str_starts_with($key, 'MELLON_ASSERTION_ID')
    ) {
        $assertion[$key] = $value;
    }

    if (str_starts_with($key, 'MELLON_SESSION')) {
        $dom = new \DOMDocument('1.0');
        $dom->preserveWhiteSpace = true;
        $dom->formatOutput = true;
        $dom->loadXML(base64_decode($value));
        $session = $dom->saveXML();
    }
    if (str_starts_with($key, 'MELLON_SAML_RESPONSE')) {
        $dom = new \DOMDocument('1.0');
        $dom->preserveWhiteSpace = true;
        $dom->formatOutput = true;
        $dom->loadXML(base64_decode($value));
        $saml_response = $dom->saveXML();
    }

}

$data = [
    'assertion' => $assertion,
    'attributes' => $attributes,
    'session' => $session,
    'saml_response' => $saml_response,
];

echo $template->render($data);
