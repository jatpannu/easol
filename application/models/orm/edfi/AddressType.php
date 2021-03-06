<?php

namespace Model\Edfi;

use \Gas\Core;
use \Gas\ORM;

class AddressType extends ORM {

	public $table = "edfi.AddressType";
	public $primary_key = 'AddressTypeId';


	function _init() {

		self::$relationships = [
			'StudentAddress'=> ORM::has_many('\\Model\\Edfi\\StudentAddress'),
		];

		self::$fields = [
			'AddressTypeId'    => ORM::field('int[10]'),
			'CodeValue'        => ORM::field('char[50]'),
			'Description'      => ORM::field('char[1024]'),
			'ShortDescription' => ORM::field('char[450]'),
			'Id'               => ORM::field('char[255]'),
			'LastModifiedDate' => ORM::field('datetime'),
			'CreateDate'       => ORM::field('datetime'),
		];
	}
}
