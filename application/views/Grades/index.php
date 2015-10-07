<?php extract($data); ?>
<div class="row">
    <div class="col-md-12 col-sm-12">
        <h1 class="page-header">Grades</h1>
    </div>
</div>
<div class="row">
    <div class="col-md-12 col-sm-12">
        <div class="panel panel-default">
            <div class="panel-body">
                <form class="form-inline form-horizontal undo-overrides">
               		<div class="form-group">
	                    <label for="filter['Term']">Term</label><br />
	                    <select name="filter['Term']">
	                        <option value="">All Terms</option>	                    	
	                        <?php foreach($terms as $k => $v): ?>
	                        	<option value="<?php echo $v->TermTypeId; ?>" <?php if( isset($_GET["filter['Term']"]) and $_GET["filter['Term']"] == $v->TermTypeId) {echo "selected";} ?> ><?php echo $v->CodeValue; ?></option>
	                        <?php endforeach; ?>                        
	                    </select>   
                  </div>
 				          <div class="form-group">
	                    <label for="filter['Year']">School Year</label><br />
	                    <select name="filter['Year']">
	                        <option value="">All Years</option>	                    	
	                        <?php foreach($years as $k => $v): ?>
	                        	<option value="<?php echo $v; ?>" <?php if( isset($_GET["filter['Year']"]) and $_GET["filter['Year']"] == $v) {echo "selected";} ?> ><?php echo $v; ?></option>
	                        <?php endforeach; ?>                        
	                    </select>   
                  </div>
 				          <div class="form-group">
	                    <label for="filter['Course']">Course</label><br />
	                    <select name="filter['Course']">
	                        <option value="">All Courses</option>	                    	
	                        <?php foreach($courses as $k => $v): ?>
	                        	<option value="<?php echo $v->CourseCode; ?>" <?php if( isset($_GET["filter['Course']"]) and $_GET["filter['Course']"] == $v->CourseCode) {echo "selected";} ?> ><?php echo $v->CourseTitle; ?></option>
	                        <?php endforeach; ?>                        
	                    </select>   
                  </div>
 				          <div class="form-group">
	                    <label for="filter['Educator']">Educator</label><br />
	                    <select name="filter['Educator']">
	                        <option value="">All Educators</option>	                    	
	                        <?php foreach($educators as $k => $v): ?>
	                        	<option value="<?php echo $v->StaffUSI; ?>" <?php if( isset($_GET["filter['Educator']"]) and $_GET["filter['Educator']"] == $v->StaffUSI) {echo "selected";} ?> ><?php echo $v->FullName; ?></option>
	                        <?php endforeach; ?>                        
	                    </select>   
                  </div>                                       
                  <div class="form-group">
                    <label for="filter['GradeLevel']">Grade Level</label><br />
                    <select name="filter['GradeLevel']">
	                	<option value="">All Grade Levels</option>                    	
                        <?php foreach($gradelevels as $k => $v): ?>
                        <option value="<?php echo $v->GradeLevelTypeId; ?>" <?php if( isset($_GET['Gradelevel']) and $_GET['GradeLevel'] == $v->GradeLevelTypeId) {echo "selected";} ?> ><?php echo $v->Description; ?></option>
                        <?php endforeach; ?>                        
                    </select>   
                  </div>

                  <button type="submit" class="btn btn-primary" id="grades-filter">Filter</button>
                
                </form>
            </div>
        </div>
    </div>
</div>