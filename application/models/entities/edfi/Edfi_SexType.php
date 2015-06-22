<?php
/**
 * User: Nahid Hossain
 * Email: mail@akmnahid.com
 * Phone: +880 172 7456 280
 * Date: 6/2/2015
 * Time: 9:53 PM
 */

require_once APPPATH.'/core/Easol_BaseEntity.php';
class Edfi_SexType extends Easol_baseentity {

    /**
     * labels for the database fields
     * @return array
     */
    public function labels()
    {
        return [
            'SexTypeId'             => 'Sex Type Id',
            'CodeValue'             => 'Code Value',
            'Description'           => 'Description',
            'ShortDescription'      => 'Short Description',
            'Id'                    =>  'Id',
            'LastModifiedDate'      =>  'Last Modified Date',
            'CreateDate'            =>  'Create Date'


        ];
    }


    /**
     * return table name
     * @return string
     */
    public function getTableName()
    {
        return "edfi.SexType";
    }

}