<?php
/**
 * Created by PhpStorm.
 * User: gyufi
 * Date: 2018. 03. 19.
 * Time: 17:05
 */

use Silex\Api\ControllerProviderInterface;
use Silex\Application;

/**
 * Class DefaultController
 */
class DefaultController implements ControllerProviderInterface
{

    /**
     * @param Application $app
     *
     * @return mixed
     */
    public function connect(Application $app)
    {
        // creates a new controller based on the default route
        $controllers = $app['controllers_factory'];

        $controllers->get('/', function (Application $app) {
            return $this->defaultAction($app);
        });

        return $controllers;

    }

    /**
     * @param $app
     *
     * @return mixed
     */
    private function defaultAction($app)
    {
        $assertions = array();
        $assertions[] = '';

        $xmlfile = '/etc/shibboleth/attribute-map.xml';

        $attributeMap = new AttributeMap($xmlfile, $app['config']['attributetypes']);
        $map = $attributeMap->getMapping();

        foreach ($map as $key => $attribute) {
            $value = null;
            if (array_key_exists($key, $_SERVER)) {
                $value = $_SERVER[$key];
            }
            $map[$key]['value'] = $value;
        }

        $shibbolethVars = array();
        $metadataVars = array();
        $assertionUrls = array();
        foreach ($_SERVER as $key => $value) {
            if (preg_match("/^Shib-/", $key)) {
                $shibbolethVars[$key] = $value;
            }
            if (preg_match("/^Meta-/", $key)) {
                $metadataVars[$key] = $value;
            }
            if (preg_match('/^Shib-Assertion-\d/', $key)) {
                $assertionUrls[$key]['url'] = $value;
                $assertionUrls[$key]['xml'] = file_get_contents(preg_replace('#^.*/Shibboleth.sso#', 'http://localhost/Shibboleth.sso', $value));
            }

        }
        $shibbolethXml = file_get_contents('/etc/shibboleth/shibboleth2.xml');

        return $app['twig']->render('default.html.twig', array(
            'brand'           => $app['config']['brand'],
            'logo'            => $app['config']['logo'],
            'logo_url'        => getenv("LOGO_URL"),
            'attributes'      => $map,
            'logged_in'       => array_key_exists("Shib-Session-ID", $_SERVER) && $_SERVER["Shib-Session-ID"],
            'assertions'      => $assertions,
            'assertion_urls'  => $assertionUrls,
            'shibboleth_vars' => $shibbolethVars,
            'metadata_vars'   => $metadataVars,
            'server'          => $_SERVER,
            'shibboleth_xml'  => $shibbolethXml,
            'custom_login_url' => getenv('CUSTOM_LOGIN_URL'),
        ));
    }
}
