<?php
// web/index.php
require_once __DIR__.'/../vendor/autoload.php';
require_once __DIR__.'/../src/DefaultController.php';
require_once __DIR__.'/../src/AttributeMap.php';

$app = new Silex\Application();

// config
$provider = new \Misantron\Silex\Provider\ConfigServiceProvider(
    new \Misantron\Silex\Provider\Adapter\YamlConfigAdapter(),
    array(__DIR__ . '/../config/config.yml'),
    array('root_path' => realpath(__DIR__ . '/..'))
);
$app->register($provider);

//twig
$app->register(new Silex\Provider\TwigServiceProvider(), array('twig.path' => __DIR__.'/../views',));

// VarDumper
$app->register(new Silex\Provider\VarDumperServiceProvider());

// controller
$app->mount('/', new DefaultController());

$app->run();




