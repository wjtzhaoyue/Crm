<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
String basePath =request.getScheme() +"://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath()+ "/";
%>
<!DOCTYPE html>
<html>
<head>
	<base href="<%=basePath%>">
<meta charset="UTF-8">

<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
<link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />

<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>

	<link rel="stylesheet" type="text/css" href="jquery/bs_pagination/jquery.bs_pagination.min.css">
	<script type="text/javascript" src="jquery/bs_pagination/jquery.bs_pagination.min.js"></script>
	<script type="text/javascript" src="jquery/bs_pagination/en.js"></script>

	<script type="text/javascript">

	$(function(){
//时间插件
		$(".time").datetimepicker({                //这里使用$(".time")是class ，因为会多处用到这个事件插件，
			minView: "month",
			language:  'zh-CN',
			format: 'yyyy-mm-dd',
			autoclose: true,
			todayBtn: true,
			pickerPosition: "bottom-left"
		});
//为创建按钮绑定事件，打开添加操作的模态窗口
		$("#addBtn").click(function () {
			//alert(123);
			//$("#createActivityModal").modal("show");//show 要加上引号

		//
			$.ajax({
				url:"workbench/activity/getUserList.do",    //这里第一个/不要
				data:{                                 // 这里是你传递的数据
				},
				type:"get",
				dataType: "json",                                 //这里是你想要的数据类型
				success:function (data) {
					var html="<option></option>";

                    var id="${user.id}"
					$.each(data,function (i,n) {

						if(n.id==id){//////////////疑问为什么这里== 可以判断数据库中的字符串/////////////!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
							html=html+" <option value=' "+n.id +" ' selected > "+n.name+" </option>"
						}

						else
					 	html +="<option value=' "+n.id +" ' > "+n.name+" </option>"
					 })


					$("#create-owner").html(html);


					$("#createActivityModal").modal("show");//show 要加上引号

				}
			})

		})

		$("#saveBtn").click(function () {
			$.ajax({
				url:"workbench/activity/save.do",
				data:{
					"owner":$.trim($("#create-owner").val()),//这行代表着将下拉列表中选好的值传上去
					"name":$.trim($("#create-name").val()),
			        "startDate":$.trim($("#create-startDate").val()),
			        "endDate":$.trim($("#create-endDate").val()),
					"cost":$.trim($("#create-cost").val()),
					"description":$.trim($("#create-description").val())
				},
				type:"post",
				dataType: "json",                                 //这里是你想要的数据类型
				success:function (data) {
					if(data.success){

                        pageList(1,$("#activityPage").bs_pagination('getOption', 'rowsPerPage'));

                        $("#activityAddForm")[0].reset();           //这行代码按照视频课中的做法，能清空窗口。
						$("#createActivityModal").modal("hide")
					}
					else {
						alert("添加市场活动失败");
					}
				}
			})

		})

		//页面加载完毕，自动进行后台查询，填充页面的分页操作
		pageList(1,2);

		//条件查询加上分页查询
		$("#searchBtn").click(function () {

			$("#hidden-name").val($.trim($("#search-name").val()))
			$("#hidden-owner").val($.trim($("#search-owner").val()))
			$("#hidden-startDate").val($.trim($("#search-startDate").val()))
			$("#hidden-endDate").val($.trim($("#search-endDate").val()))

			pageList(1,2);

		})

		//点击一个总的，可以实现全选.即为全选的复选框绑定事件
		//qx：表示全选的那个复选框。xz：表示子选项的复选框
		$("#qx").click(function () {
			$("input[name=xz]").prop("checked",this.checked)  //这行表示：如果this。checked为true，那么给每一个类型为
			                                                  //input且name=xz的标签赋值为checked

		})

		//点击下面的单个复选框，去决定总的复选框该不该画上

		//下面的这种做法是不行的。因为在each中动态拼接生成的元素。不能以普通绑定事件的形式来进行操作。
		/*$("input[name=xz]").click(function()){
		alert(123);
		}

		 */

		//动态生成的元素，要以on方法的形式来触发事件
		//语法：$(被绑定元素的有效外层元素。若他外层的元素仍是动态生成的，那么继续往外面找).on(绑定事件的形式,需要绑定元素的jquery对象，回调函数)
		//
		$("#activityBody").on("click",$("input[name=xz]"),function () {
			$("#qx").prop("checked",$("input[name=xz]").length==$("input[name=xz]:checked").length)
		})


		//为删除按钮创建单击事件。支持批量删除
		$("#deleteBtn").click(function () {
			var $xz=$("input[name=xz]:checked")
            if($xz.length==0){
            	alert("请选择需要删除的记录")
			}else {
				//url:http://localhost:8080/crm/workbench/activity/delete.do?id=xxx&id=xxx
				//肯定选了复选框，可能是一个，也可能是多个.这里的复选框是动态生成的，而且，选中了复选框就等于得到了该活动的id值
				//获取选中的复选框的id，作为参数上传到地址栏。
				//因为这里是多个id，即同一个参数名字，多个值。所以使用字符串拼接的方式。
            	if(confirm("确定删除选中的市场活动吗？")){
					var param=""
					for(var i=0 ;i<$xz.length;i++){
						param += "id="+$($xz[i]).val() // 这里的$$有两个.第一个表示将jquery数组中的单个（即dom对象）转换为jquery对象。
						// 这样才能使用val（）。这里还可以写作$xz[i].value
						if(i<$xz.length-1){
							param += "&";       //这里拼接的是地址栏的参数。因为是参数。所以地址栏会自动在第一个参数前添加”？“
						}
					}
					//alert(param)
					$.ajax({
						url:"workbench/activity/delete.do",
						data:param,          //因为这次是按照key=value&key=value  的形式传/!!!!!!!!!!！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！!!!1这里不要{}
						type:"post",     //删除操作，使用post
						dataType: "json",                                 //这里是你想要的数据类型
						success:function (data) {
							/*
                            data
                            {"success":true/false}
                             */
							if(data.success){
                                pageList(1,$("#activityPage").bs_pagination('getOption', 'rowsPerPage'));

                                // pageList(1,2)

							}else {
								alert("删除市场活动失败")
							}


						}
					})

				}

			}
		})


		$("#editBtn").click(function () {
			 var $xz=$("input[name=xz]:checked")
			if($xz.length==0){
				alert("请选择你要修改的活动")
			}
			else  if($xz.length>1){
				alert("每次修改只能选择一个活动")
			}
			else {
				var id=$xz.val() /*注意这里：因为走到这一步，说明jquery对象只有一个元素。当你非常确定jquery只有
				                一个对象的时候。可以是value和val通用。否则只能遍历jquery数组，使用下标。
				                然后用value的到值
				                */
				$.ajax({
					url:"workbench/activity/getUserListAndActivity.do",
					data:{
						"id":id,                           // 传递过去的被选中的活动的id!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
					},
					type:"get",
					dataType: "json",                                 //这里是你想要的数据类型
					success:function (data) {
						/*
						data
						用户对象
						市场活动列表
						{"uList":[{用户1}，{2}，{3}]，"a":{一条市场活动}}
						*/



						var html="<option></option>";

						$.each(data.uList,function (i,n) {
							if(data.a.owner==n.id){
								html += " <option value='"+n.id+" 'selected>"+n.name+"</option>"

							}
							else
								html += " <option value='"+n.id+"'>"+n.name+"</option>"


						})

						$("#edit-owner").html(html);


						$("#edit-id").val(data.a.id) //这个是从后台传递回来的id！！！！！！！！！！！！！！
						$("#edit-name").val(data.a.name)
						$("#edit-startDate").val(data.a.startDate)
						$("#edit-endDate").val(data.a.endDate)
						$("#edit-cost").val(data.a.cost)
						$("#edit-description").val(data.a.description)

						//所有的东西都写好后，显示出来模态窗口
						$("#editActivityModal").modal("show")

					}
				})


			}

		})

		$("#updateBtn").click(function () {
			//记住 添加操作和修改操作的步骤几乎一模一样。在实际开发过程中，也是先做添加操作，再做修改更新操作


			$.ajax({
				url:"workbench/activity/update.do",
				data:{
					"id":$.trim($("#edit-id").val()),
					"owner":$.trim($("#edit-owner").val()),//这行代表着将下拉列表中选好的值传上去
					"name":$.trim($("#edit-name").val()),
					"startDate":$.trim($("#edit-startDate").val()),
					"endDate":$.trim($("#edit-endDate").val()),
					"cost":$.trim($("#edit-cost").val()),
					"description":$.trim($("#edit-description").val())
				},
				type:"post",
				dataType: "json",                                 //这里是你想要的数据类型
				success:function (data) {
					if(data.success){
						pageList($("#activityPage").bs_pagination('getOption', 'currentPage')
								,$("#activityPage").bs_pagination('getOption', 'rowsPerPage'));

						// pageList(1,2)//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1
						//$("#activityAddForm")[0].reset();           //这行代码按照视频课中的做法，再次打开添加的时候能清空窗口。
						$("#editActivityModal").modal("hide")
					}
					else {
						alert("修改市场活动失败");
					}
				}
			})




		})

	});
	//主要是想获得这两个参数。然后这个方法会在6个地方使用到
	//（1）点击左侧菜单栏的市场活动的超链接，需要刷新市场活动列表，调用pageList方法
	//（2）添加，修改，删除后，需要刷新市场活动列表，调用pageList方法..............这里算是三处用到
	//(3)点击查询按钮的时候，需要刷新市场活动列表，调用pageList方法
	//(4)点击下面的分页组件1 2 3 4等等 页码的时候，需要刷新市场活动列表，调用pageList方法。这里也会用用到
	function pageList(pageNo,pageSize) {
		//在进行查询之前，即进行分页操作的时候。将上一次查询时候，存在隐藏域中的值，赋给一系列查询操作的输入框。
		// 防止一些细节上的体验不舒服
		//解决的问题是：当用户在输入一些查询条件的时候，但是没有点击搜索，这时候如果你不处理，
		//再点击下面的第x页的时候，他会自动执行分页函数。那么他会使用你现在输入的查询条件。尽管你此时并没有点击搜素
		//然后跳到你现在所输入的数据对应查询结果的x页
		// 他会将你现在输入的数据使用上，跳转到你输入的那个结果的页面。
		//这个时候，我们可以使用一个隐藏域去保存，用户上次查询时输入的信息。默认按照之前的来
		$("#search-name").val($.trim($("#hidden-name").val()))
		$("#search-owner").val($.trim($("#hidden-owner").val()))
		$("#search-startDate").val($.trim($("#hidden-startDate").val()))
		$("#search-endDate").val($.trim($("#hidden-endDate").val()))

		/*每次进行分页的时候，记得将总的复选框的钩给取消掉。这里也是为了防止。
		在进行删除操作时候，全选后进行删除，然后总的复选框还在钩着的情况
		这里关于删除时候，全选删除的情况下。取消分页后全选的复选框的操作，还可以在删除操作后进行处理
		 */

		$("#qx").prop("checked",false) //checked记得加上引号！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！

		//alert("展现市场活动列表");
		//使用ajax局部刷新
		$.ajax({
			url:"workbench/activity/pageList.do",
			data:{
				"pageNo":pageNo,
				"pageSize":pageSize,
				<%--"id":${}--%>//这里没有要id！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
				"owner":$.trim($("#search-owner").val()),
				"name":$.trim($("#search-name").val()),
				"startDate":$.trim($("#search-startDate").val()),
				"endDate":$.trim($("#search-endDate").val())
			},
			type:"get",
			dataType: "json",                                 //这里是你想要的数据类型
			success:function (data) {

				//这里需要返回两条数据.把两个数据封装成一个对象了
				// 一是：总的数据条目数，二是：活动的列表集合
				//{"total":100,"dataList":[{活动1},{活动2},{活动3}，.....]}
				var html="";
				$.each(data.dataList,function (i,n) {

				html += '<tr class="active">';
				html += '<td><input type="checkbox" name="xz" value="'+n.id+'" /></td>';//这里要加上id！想明白为什么！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
				html += '<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href=\'workbench/activity/detail.do?id='+n.id+'\';">'+n.name+'</a></td>';

					//活动表中的owener是一串字母，应该转化为user表中的name.这一点在sql语句中体现!!!!!!！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
				html += '<td>'+n.owner+'</td>';

				html += '<td>'+n.startDate+'</td>';
				html += '<td>'+n.endDate+'</td>';
				html += '</tr>';
				})
				$("#activityBody").html(html);

				var totalPages=data.total%pageSize==0 ? data.total/pageSize:parseInt(data.total/pageSize)+1; //注意这里处理的parseInt
				//数据处理完毕后，结合分页插件，对前端展现分页信息
				$("#activityPage").bs_pagination({
					currentPage: pageNo, // 页码
					rowsPerPage: pageSize, // 每页显示的记录条数
					maxRowsPerPage: 20, // 每页最多显示的记录条数
					totalPages: totalPages, // 总页数
					totalRows: data.total, // 总记录条数
					visiblePageLinks: 3, // 显示几个卡片
					showGoToPage: true,
					showRowsPerPage: true,
					showRowsInfo: true,
					showRowsDefaultInfo: true,
					//该回调函数是在，点击分页组件的时候触发的；
					onChangePage : function(event, data){
						pageList(data.currentPage , data.rowsPerPage);//这个data  不是我们自己传的那个data。这里的数据不要动
					}
				});
			}
		})
	}
	
</script>
</head>
<body>
<%--隐藏区域.想放哪里放哪里。因为是通过id来找他们的，而id是唯一的--%>

         <input type="hidden" id="hidden-name">
		 <input type="hidden" id="hidden-owner">
		 <input type="hidden" id="hidden-startDate">
		 <input type="hidden" id="hidden-endDate">



	<!-- 创建市场活动的模态窗口 -->
	<div class="modal fade" id="createActivityModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel1">创建市场活动</h4>
				</div>
				<div class="modal-body">
				
					<form id="activityAddForm" class="form-horizontal" role="form">
					
						<div class="form-group">
							<label for="create-owner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control"  id="create-owner" v>
<%--								  <option>zhangsan</option>--%>
<%--								  <option>lisi</option>--%>
<%--								  <option>wangwu</option>--%>
								</select>
							</div>
                            <label for="create-name" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-name">
                            </div>
						</div>
						
						<div class="form-group">
							<label for="create-startDate" class="col-sm-2 control-label">开始日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="create-startDate" readonly>
							</div>
							<label for="create-endDate" class="col-sm-2 control-label">结束日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="create-endDate" readonly>
							</div>
<%--				class="form-control time"  time 前面有空格，说明这是俩个类。这里的time是时间组件			--%>
						</div>
                        <div class="form-group">

                            <label for="create-cost" class="col-sm-2 control-label">成本</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-cost">
                            </div>
                        </div>
						<div class="form-group">
							<label for="create-description" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="create-description"></textarea>
							</div>
						</div>
						
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="saveBtn">保存</button>
				</div>
			</div>
		</div>
	</div>
	
	<!-- 修改市场活动的模态窗口 -->
	<div class="modal fade" id="editActivityModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel2">修改市场活动</h4>
				</div>
				<div class="modal-body">
				
					<form class="form-horizontal" role="form">

						<input type="hidden" id="edit-id">  <%--        这行是自己添加的id--%>

						<div class="form-group">
							<label for="edit-owner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-owner">

								</select>
							</div>
                            <label for="edit-name" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-name" value="发传单">
                            </div>
						</div>

						<div class="form-group">
							<label for="edit-startDate" class="col-sm-2 control-label">开始日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="edit-startDate" readonly  >
							</div>
							<label for="edit-endDate" class="col-sm-2 control-label">结束日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="edit-endDate" readonly >
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-cost" class="col-sm-2 control-label">成本</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-cost" value="5,000">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-description" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
                               <%--
                                       关于文本域textarea：
                                       （1）一定是要以标签对。不能省略写/的形式来呈现，正常情况下标签对要紧紧挨着
                                      （2） textarea虽然是以标签对的形式存在，但是它也属于表单元素范畴。像input
                                         那样来操作，即使textarea没有value值。
                                         （3）取值的时候统一使用的是val（），而不是html()
                                       --%>
								<textarea class="form-control" rows="3" id="edit-description"></textarea>
							</div>
						</div>
						
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" data-dismiss="modal" id="updateBtn">更新</button>
				</div>
			</div>
		</div>
	</div>
	
	
	
	
	<div>
		<div style="position: relative; left: 10px; top: -10px;">
			<div class="page-header">
				<h3>市场活动列表</h3>
			</div>
		</div>
	</div>
	<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">
		<%--	查询框--%>
		<div style="width: 100%; position: absolute;top: 5px; left: 10px;">
		
			<div class="btn-toolbar" role="toolbar" style="height: 80px;">
				<form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">名称</div>
				      <input class="form-control" type="text" id="search-name">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">所有者</div>
				      <input class="form-control" type="text" id="search-owner">
				    </div>
				  </div>


				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">开始日期</div>
					  <input class="form-control" type="text" id="search-startDate" />
				    </div>
				  </div>
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">结束日期</div>
					  <input class="form-control" type="text" id="search-endDate">
				    </div>
				  </div>
				  
				  <button type="button" id="searchBtn" class="btn btn-default" >查询</button>   <%--这里改为button类型	  --%>
<%--				  --%>
				</form>
			</div>

			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 5px;">
				<div class="btn-group" style="position: relative; top: 18%;">
				  <button type="button" class="btn btn-primary" id="addBtn"><span class="glyphicon glyphicon-plus"></span> 创建</button>
				  <button type="button" class="btn btn-default" id="editBtn"><span class="glyphicon glyphicon-pencil"></span> 修改</button>
				  <button type="button" class="btn btn-danger" id="deleteBtn"><span class="glyphicon glyphicon-minus"></span> 删除</button>
				</div>
				
			</div>

			<div style="position: relative;top: 10px;">
				<table class="table table-hover">
					<thead>
						<tr style="color: #B3B3B3;">
							<td><input type="checkbox" id="qx" /></td>
							<td>名称</td>
                            <td>所有者</td>
							<td>开始日期</td>
							<td>结束日期</td>
						</tr>
					</thead>
					<tbody id="activityBody">
<%--						<tr class="active">--%>
<%--							<td><input type="checkbox" /></td>--%>
<%--							<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='workbench/activity/detail.jsp';">发传单</a></td>--%>
<%--                            <td>zhangsan</td>--%>
<%--							<td>2020-10-10</td>--%>
<%--							<td>2020-10-20</td>--%>
<%--						</tr>--%>
<%--                        <tr class="active">--%>
<%--                            <td><input type="checkbox" /></td>--%>
<%--                            <td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='detail.jsp';">发传单</a></td>--%>
<%--                            <td>zhangsan</td>--%>
<%--                            <td>2020-10-10</td>--%>
<%--                            <td>2020-10-20</td>--%>
<%--                        </tr>--%>
					</tbody>
				</table>
			</div>

			<div style="height: 50px; position: relative;top: 30px;">
				<div id="activityPage">

				</div>
			</div>
			
		</div>
	</div>
</body>
</html>