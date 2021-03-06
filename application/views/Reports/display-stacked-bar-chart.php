<?php /* @var $model Easol_Report */ ?>

<?php
$jsonData=[];
$_i=0;
$axisX="";
$axisY="";
$_columns=[];

$ReportData = $model->getReportData();
if (!empty($ReportData)) {
    foreach($model->getReportData() as $data){
        $_j=0;
        $_k=0;
        foreach($data as $key => $property){
            if($_i==0){

                $_columns[] = $key;
            }
            if($_j==0){
                $jsonData[$_i]["key"] = $property;
            }
            else {
                $jsonData[$_i]["values"][$_k]['label'] = $key;
                $jsonData[$_i]["values"][$_k]['value'] = $property;
                $_k++;
            }
            $_j++;

        }
        $_i++;
    }
}

$ReportData = $this->db->query($model->getReportQuery());
if (!empty($ReportData)) {
    foreach($ReportData->list_fields() as $key){
        $_columns[] = $key;
    }
}

?>
<?php if($displayTitle==true){ ?>
<div class="row">
    <div class="col-md-12 col-sm-12">
        <h1 class="page-header">Flex Reports : Stacked Bar : <?= $model->ReportName ?></h1>
    </div>
</div>
<?php } ?>
<div class="row">
    <div class="col-md-12 col-sm-12">
        <div class="panel panel-default">
             <?php if($filter = $model->getFilters()): ?>
                <div class="panel-body" id="filter-destination">
                    <?php $this->load->view('Reports/_report-filters',  ['filter'=>$filter, 'report'=>$model]); ?>
                </div>
            <?php endif;   ?>
            <div class="panel-body">
                <style>
                    #chart1, svg {
                      margin: 0px;
                      padding: 0px;
                      height: 100%;
                      width: 100%;
                    }
                </style>

                <div id="chart1" class='with-3d-shadow with-transitions'>
                    <svg></svg>
                </div>

                <script>
                  /* */ var long_short_data = <?= json_encode($jsonData) ?>; /* */

                    var chart;
                    nv.addGraph(function() {

                        chart = nv.models.multiBarHorizontalChart()
                            .x(function(d) { return d.label })
                            .y(function(d) { return d.value })
                            .margin({top: 30, right: 60, bottom: 60, left: 120})
                           // .yErr(function(d) { return [-Math.abs(d.value * Math.random() * 0.3), Math.abs(d.value * Math.random() * 0.3)] })
                           // .barColor(d3.scale.category20().range())
                            .showValues(true)           //Show bar value next to each bar.
                            .tooltips(true)             //Show tooltips on hover.
                           // .duration(350)
                           // .margin({left: 100})
                              .showControls(true)        //Allow user to switch between "Grouped" and "Stacked" mode.
                              .stacked(true);
                        chart.xAxis.axisLabel('<?= $model->LabelY ?>').axisLabelDistance(35);
                        chart.yAxis.tickFormat(d3.format(',.2f'));
                        chart.yAxis.axisLabel('<?= $model->LabelX ?>');

                        d3.select('#chart1 svg')
                            .datum(long_short_data)
                            .call(chart);
                        nv.utils.windowResize(chart.update);
                        chart.dispatch.on('stateChange', function(e) { nv.log('New State:', JSON.stringify(e)); });
                        chart.state.dispatch.on('change', function(state){
                            nv.log('state', JSON.stringify(state));
                        });
                        return chart;
                    });
                </script>

            </div>
         </div>
     </div>
</div>

<?php if(isset($pageNo) && !empty($_columns)) { ?>
<?php $filter_option = 'no'; ?>
<div class="row">
    <div class="col-md-12">
        <?php include('display-table-view.php'); ?>
    </div>
</div>
<?php } ?>