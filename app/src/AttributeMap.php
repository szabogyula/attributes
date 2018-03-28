<?php

/**
 * Created by PhpStorm.
 * User: gyufi
 * Date: 2018. 03. 19.
 * Time: 17:27
 */
class AttributeMap
{
    public $mapping = array();

    public $mandatory;

    public $recommended;

    public function __construct($xmlfile, $config)
    {
        $this->mandatory = $config['mandatory'];
        $this->recommended = $config['recommended'];

        $attribute_map_lines = file($xmlfile);
        $attribute_map = '';
        foreach ($attribute_map_lines as $line) {
            $attribute_map .= $line;
        }

        $p = xml_parser_create();
        xml_parse_into_struct($p, $attribute_map, $vals, $index);
        xml_parser_free($p);
        foreach ($vals as $element) {
            if ($element['tag'] == 'ATTRIBUTE' && isset($element['attributes']['ID'])) {

                $this->mapping[$element['attributes']['ID']]['name'][] = $element['attributes']['NAME'];

                if (in_array($element['attributes']['NAME'], $this->mandatory)) {
                    $this->mapping[$element['attributes']['ID']]['type'] = "mandatory";
                } elseif (in_array($element['attributes']['NAME'], $this->recommended)) {
                    $this->mapping[$element['attributes']['ID']]['type'] = "recommended";
                } else {
                    $this->mapping[$element['attributes']['ID']]['type'] = null;
                }

            }
        }
    }

    /**
     * @return array
     */
    public function getMapping()
    {
        return $this->mapping;
    }

    /**
     * @return array
     */
    public function getMandatory(): array
    {
        return $this->mandatory;
    }

    /**
     * @return array
     */
    public function getRecommended(): array
    {
        return $this->recommended;
    }

}