<?php
/**
 * User: Nahid Hossain
 * Email: mail@akmnahid.com
 * Phone: +880 172 7456 280
 * Date: 6/1/2015
 * Time: 11:39 PM
 */
?>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title><?= $title ?></title>
    <!-- Bootstrap Styles-->
    <link href="assets/css/bootstrap.css" rel="stylesheet"/>
    <!-- FontAwesome Styles-->
    <link href="assets/css/font-awesome.css" rel="stylesheet"/>
    <!-- Custom Styles-->
    <link href="assets/css/custom-styles.css" rel="stylesheet"/>
    <!-- Google Fonts-->
    <link href='http://fonts.googleapis.com/css?family=Open+Sans' rel='stylesheet' type='text/css'/>
</head>
<body>
    <div id="wrapper">
        <!--/. NAV TOP  -->
        <nav class="navbar-default navbar-side" role="navigation">
            <div class="sidebar-collapse">
                <a class="navbar-brand" href="<?= site_url("/") ?>"><img src="<?= site_url("/assets/img/easol_logo.png") ?>"/></a>
                <ul class="nav" id="main-menu" style="padding-top: 80px;">
                    <li>
                        <a href="<?= site_url("/dashboard") ?>"><i class="fa fa-dashboard"></i> Dashboard</a>
                    </li>
                    <li>
                        <a href="<?= site_url("/schools") ?>"><i class="fa fa-edit"></i> Schools</a>
                    </li>
                    <li>
                        <a href="<?= site_url("/grades") ?>"><i class="fa fa-desktop"></i> Grade Reporting</a>
                    </li>
                    <li>
                        <a href="<?= site_url("/sections") ?>"><i class="fa fa-bar-chart-o"></i> Class Reporting</a>
                    </li>
                    <li>
                        <a href="<?= site_url("/attendance") ?>"><i class="fa fa-qrcode"></i> Attendance</a>
                    </li>

                    <li>
                        <a href="<?= site_url("/assessments") ?>"><i class="fa fa-table"></i> Assessments</a>
                    </li>
                    <li>
                        <a href="<?= site_url("/reports") ?>"><i class="fa fa-edit"></i> Flex Reports</a>
                    </li>
                    <li>
                        <a href="<?= site_url("/admin") ?>"><i class="fa fa-edit"></i> Administration</a>
                    </li>
                </ul>

            </div>

        </nav>
        <!-- /. NAV SIDE  -->
        <div id="page-wrapper">
            <div id="page-inner">
                <div class="row page-content">
                <?= $content ?>
                </div>
                <div class="row">
                    <div class="col-md-8" style="color: #cccccc;">
                        This computer system is the property of the the Center of Education Innovation. It is for authorized
                        use only.
                        Unauthorized or improper use of this system may result in civil charges and/or criminal penalties.
                    </div>
                </div>
            </div>
            <!-- /. ROW  -->
            <footer></footer>
            <!-- /. PAGE INNER  -->
        </div>
    <!-- /. PAGE WRAPPER  -->
    </div>
    <!-- /. WRAPPER  -->
    <!-- JS Scripts-->
    <!-- jQuery Js -->
    <script src="assets/js/jquery-1.10.2.js"></script>
    <!-- Bootstrap Js -->
    <script src="assets/js/bootstrap.min.js"></script>
    <!-- Metis Menu Js -->
    <script src="assets/js/jquery.metisMenu.js"></script>
    <!-- Custom Js -->
    <script src="assets/js/custom-scripts.js"></script>


</body>
</html>