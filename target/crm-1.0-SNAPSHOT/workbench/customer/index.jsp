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
			pickerPosition: "top-left"
		});
//定制字段(前端自己写的)
		$("#definedColumns > li").click(function(e) {
			//防止下拉菜单消失
	        e.stopPropagation();
	    });
//页面加载完毕，自动进行后台查询，填充页面的分页操作
		pageList(1,2);
		//条件查询加上分页查询
		$("#searchBtn").click(function () {
			$("#hidden-name").val($.trim($("#search-name").val()))
			$("#hidden-owner").val($.trim($("#search-owner").val()))
			$("#hidden-phone").val($.trim($("#search-phone").val()))
			$("#hidden-website").val($.trim($("#search-website").val()))
			pageList(1,2);
		})
//为创建按钮绑定事件，打开添加操作的模态窗口
		$("#addBtn").click(function () {
			$.ajax({
				url:"workbench/customer/getUserList.do",    //这里第一个/不要
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


					$("#createCustomerModal").modal("show");//show 要加上引号

				}
			})

		})
//为创建按钮打开的页面里的保存按钮绑定事件。
		$("#saveBtn").click(function () {
			$.ajax({
				url:"workbench/customer/save.do",
				data:{
					"owner":$.trim($("#create-owner").val()),//这行代表着将下拉列表中选好的值传上去
					"name":$.trim($("#create-name").val()),
					"website":$.trim($("#create-website").val()),
					"phone":$.trim($("#create-phone").val()),
					"description":$.trim($("#create-description").val()),
					"contactSummary":$.trim($("#create-contactSummary").val()),
					"nextContactTime":$.trim($("#create-nextContactTime").val()),
					"address":$.trim($("#create-address").val()),
				},
				type:"post",
				dataType: "json",                                 //这里是你想要的数据类型
				success:function (data) {
					if(data.success){

						pageList(1,$("#customerPage").bs_pagination('getOption', 'rowsPerPage'));

						$("#customerAddForm")[0].reset();           //这行代码按照视频课中的做法，能清空窗口。
						$("#createCustomerModal").modal("hide")
					}
					else {
						alert("添加客户失败");
					}
				}
			})

		})
//一键全选
		$("#qx").click(function () {
			$("input[name=xz]").prop("checked",this.checked)  //这行表示：如果this。checked为true，那么给每一个类型为
															  //input且name=xz的标签赋值为checked
		})
//反向全选
		$("#customerBody").on("click",$("input[name=xz]"),function () {
			$("#qx").prop("checked",$("input[name=xz]").length==$("input[name=xz]:checked").length)
		})
//修改交易的操作（点击修改图标）
		$("#editBtn").click(function () {
			var $xz=$("input[name=xz]:checked")
			if($xz.length==0){
				alert("请选择你要修改的客户")
			}
			else  if($xz.length>1){
				alert("每次修改只能选择一个客户")
			}
			else {
				var id=$xz.val() /*注意这里：因为走到这一步，说明jquery对象只有一个元素。当你非常确定jquery只有
				                一个对象的时候。可以是value和val通用。否则只能遍历jquery数组，使用下标。
				                然后用value的到值
				                */
				$.ajax({
					url:"workbench/customer/getUserListAndCustomer.do",
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
						{"uList":[{用户1}，{2}，{3}]，"c":{一条客户信息}}
						*/
						var html="<option></option>";

						$.each(data.uList,function (i,n) {
							if(data.c.owner==n.id){
								html += " <option value='"+n.id+" 'selected>"+n.name+"</option>"

							}
							else
								html += " <option value='"+n.id+"'>"+n.name+"</option>"


						})

						$("#edit-owner").html(html);


						$("#edit-id").val(data.c.id) //这个是从后台传递回来的id！必须要。这里也可以直接写从前端得到的id。！！！！！！！！！！！！！

						//$("#edit-owner").val(data.c.owner)
						$("#edit-name").val(data.c.name)
						$("#edit-phone").val(data.c.phone)
						$("#edit-website").val(data.c.website)
						$("#edit-description").val(data.c.description)
						$("#edit-contactSummary").val(data.c.contactSummary)
						$("#edit-nextContactTime").val(data.c.nextContactTime)
						$("#edit-address").val(data.c.address)

						//所有的东西都写好后，显示出来模态窗口
						$("#editCustomerModal").modal("show")

					}
				})


			}

		})
//修改后的更新按钮的绑定事件
		$("#updateBtn").click(function () {
			//记住 添加操作和修改操作的步骤几乎一模一样。在实际开发过程中，也是先做添加操做，再做修改更新操作


			$.ajax({
				url:"workbench/customer/update.do",
				data:{
					"id":$.trim($("#edit-id").val()),
					"owner":$.trim($("#edit-owner").val()),//这行代表着将下拉列表中选好的值传上去
					"name":$.trim($("#edit-name").val()),
					"website":$.trim($("#edit-website").val()),
					"phone":$.trim($("#edit-phone").val()),
					"description":$.trim($("#edit-description").val()),
					"contactSummary":$.trim($("#edit-contactSummary").val()),
					"nextContactTime":$.trim($("#edit-nextContactTime").val()),
					"address":$.trim($("#edit-address").val()),
				},
				type:"post",
				dataType: "json",                                 //这里是你想要的数据类型
				success:function (data) {
					if(data.success){
						pageList($("#customerPage").bs_pagination('getOption', 'currentPage')
								,$("#customerPage").bs_pagination('getOption', 'rowsPerPage'));

						// pageList(1,2)//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1
						//$("#activityAddForm")[0].reset();           //这行代码按照视频课中的做法，再次打开添加的时候能清空窗口。
						$("#editCustomerModal").modal("hide")
					}
					else {
						alert("修改客户信息失败");
					}
				}
			})




		})
//删除客户
		$("#deleteBtn").click(function () {
			var $xz=$("input[name=xz]:checked")
			if($xz.length==0){
				alert("请选择需要删除的客户")
			}else {
				//url:http://localhost:8080/crm/workbench/customer/delete.do?id=xxx&id=xxx
				//肯定选了复选框，可能是一个，也可能是多个.这里的复选框是动态生成的，而且，选中了复选框就等于得到了该活动的id值
				//获取选中的复选框的id，作为参数上传到地址栏。
				//因为这里是多个id，即同一个参数名字，多个值。所以使用字符串拼接的方式。
				if(confirm("确定删除选中的客户吗？")){
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
						url:"workbench/customer/delete.do",
						data:param,          //因为这次是按照key=value&key=value  的形式传/!!!!!!!!!!！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！!!!1这里不要{}
						type:"post",     //删除操作，使用post
						dataType: "json",                                 //这里是你想要的数据类型
						success:function (data) {
							/*
                            data
                            {"success":true/false}
                             */
							if(data.success){
								pageList(1,$("#customerPage").bs_pagination('getOption', 'rowsPerPage'));

								// pageList(1,2)

							}else {
								alert("删除客户失败")
							}


						}
					})

				}

			}
		})




	});



    //函数
//分页函数
	function pageList(pageNo,pageSize) {
		$("#search-name").val($.trim($("#hidden-name").val()))
		$("#search-owner").val($.trim($("#hidden-owner").val()))
		$("#search-phone").val($.trim($("#hidden-phone").val()))
		$("#search-website").val($.trim($("#hidden-website").val()))

		/*每次进行分页的时候，记得将总的复选框的钩给取消掉。这里也是为了防止。
		在进行删除操作时候，全选后进行删除，然后总的复选框还在钩着的情况
		这里关于删除时候，全选删除的情况下。取消分页后全选的复选框的操作，还可以在删除操作后进行处理
		 */

		$("#qx").prop("checked",false) //checked记得加上引号！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！

		//alert("展现市场活动列表");
		//使用ajax局部刷新
		$.ajax({
			url:"workbench/customer/pageList.do",
			data:{
				"pageNo":pageNo,
				"pageSize":pageSize,
				<%--"id":${}--%>//这里没有要id！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
				"owner":$.trim($("#search-owner").val()),
				"name":$.trim($("#search-name").val()),
				"startDate":$.trim($("#search-phone").val()),
				"endDate":$.trim($("#search-website").val())
			},
			type:"get",
			dataType: "json",                                 //这里是你想要的数据类型
			success:function (data) {

				//这里需要返回两条数据.把两个数据封装成一个对象了
				// 一是：总的数据条目数，二是：客户的列表集合
				//{"total":100,"dataList":[{客户1},{客户2},{客户3}，.....]}
				var html="";
				$.each(data.dataList,function (i,n) {

					html += '<tr class="active">';
					html += '<td><input type="checkbox" name="xz" value="'+n.id+'" /></td>';//这里要加上id！想明白为什么！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
					html += '<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href=\'workbench/customer/detail.do?id='+n.id+'\';">'+n.name+'</a></td>';

					//活动表中的owener是一串字母，应该转化为user表中的name.这一点在sql语句中体现!!!!!!！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
					html += '<td>'+n.owner+'</td>';

					html += '<td>'+n.phone+'</td>';
					html += '<td>'+n.website+'</td>';
					html += '</tr>';


				})

				$("#customerBody").html(html);

				var totalPages=data.total%pageSize==0 ? data.total/pageSize:parseInt(data.total/pageSize)+1; //注意这里处理的parseInt

				//数据处理完毕后，结合分页插件，对前端展现分页信息
				$("#customerPage").bs_pagination({
					currentPage: pageNo, // 页码
					rowsPerPage: pageSize, // 每页显示的记录条数
					maxRowsPerPage: 20, // 每页最多显示的记录条数
					totalPages: totalPages, // 总页数...........................................
					totalRows: data.total, // 总记录条数.........................................

					visiblePageLinks: 3, // 显示几个卡片

					showGoToPage: true,
					showRowsPerPage: true,
					showRowsInfo: true,
					showRowsDefaultInfo: true,

					//该回调函数实在，点击分页组件的时候触发的；
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
<%--隐藏区域--%>
<input type="hidden" id="hidden-name">
<input type="hidden" id="hidden-owner">
<input type="hidden" id="hidden-phone">
<input type="hidden" id="hidden-website">

	<!-- 创建客户的模态窗口 -->
	<div class="modal fade" id="createCustomerModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel1">创建客户</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" id="customerAddForm" role="form">
					
						<div class="form-group">
							<label for="create-owner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-owner">

								</select>
							</div>
							<label for="create-name" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-name">
							</div>
						</div>
						
						<div class="form-group">
                            <label for="create-website" class="col-sm-2 control-label">公司网站</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-website">
                            </div>
							<label for="create-phone" class="col-sm-2 control-label">公司座机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-phone">
							</div>
						</div>
						<div class="form-group">
							<label for="create-description" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="create-description"></textarea>
							</div>
						</div>
						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative;"></div>

                        <div style="position: relative;top: 15px;">
                            <div class="form-group">
                                <label for="create-contactSummary" class="col-sm-2 control-label">联系纪要</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="3" id="create-contactSummary"></textarea>
                                </div>
                            </div>
                            <div class="form-group">
                                <label for="create-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
                                <div class="col-sm-10" style="width: 300px;">
                                    <input type="text" class="form-control time" id="create-nextContactTime">
                                </div>
                            </div>
                        </div>

                        <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

                        <div style="position: relative;top: 20px;">
                            <div class="form-group">
                                <label for="create-address" class="col-sm-2 control-label">详细地址</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="1" id="create-address"></textarea>
                                </div>
                            </div>
                        </div>
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="saveBtn" data-dismiss="modal">保存</button>
				</div>
			</div>
		</div>
	</div>
	
	<!-- 修改客户的模态窗口 -->
	<div class="modal fade" id="editCustomerModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel">修改客户</h4>
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
								<input type="text" class="form-control" id="edit-name" value="动力节点">
							</div>
						</div>
						
						<div class="form-group">
                            <label for="edit-website" class="col-sm-2 control-label">公司网站</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-website" >
                            </div>
							<label for="edit-phone" class="col-sm-2 control-label">公司座机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-phone" >
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-description" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="edit-description"></textarea>
							</div>
						</div>
						
						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative;"></div>

                        <div style="position: relative;top: 15px;">
                            <div class="form-group">
                                <label for="edit-contactSummary" class="col-sm-2 control-label">联系纪要</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="3" id="edit-contactSummary"></textarea>
                                </div>
                            </div>
                            <div class="form-group">
                                <label for="edit-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
                                <div class="col-sm-10" style="width: 300px;">
                                    <input type="text" class="form-control time" id="edit-nextContactTime">
                                </div>
                            </div>
                        </div>

                        <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

                        <div style="position: relative;top: 20px;">
                            <div class="form-group">
                                <label for="edit-address" class="col-sm-2 control-label">详细地址</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="1" id="edit-address"></textarea>
                                </div>
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
				<h3>客户列表</h3>
			</div>
		</div>
	</div>
	
	<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">
	
		<div style="width: 100%; position: absolute;top: 5px; left: 10px;">
		
			<div class="btn-toolbar" role="toolbar" style="height: 80px;">
				<form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">

				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">名称</div>
				      <input class="form-control" type="text" id="search-name" >
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
				      <div class="input-group-addon">公司座机</div>
				      <input class="form-control" type="text" id="search-phone">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">公司网站</div>
				      <input class="form-control" type="text" id="search-website">
				    </div>
				  </div>
<%--这里记得讲按钮改为button --%><button type="button" id="searchBtn" class="btn btn-default">查询</button>
				  
				</form>
			</div>
			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 5px;">
				<div class="btn-group" style="position: relative; top: 18%;">
				  <button type="button" class="btn btn-primary"  id="addBtn"><span class="glyphicon glyphicon-plus"></span> 创建</button>
				  <button type="button" class="btn btn-default"  id="editBtn"><span class="glyphicon glyphicon-pencil"></span> 修改</button>
				  <button type="button" class="btn btn-danger" id="deleteBtn"><span class="glyphicon glyphicon-minus" ></span> 删除</button>
				</div>
				
			</div>
			<div style="position: relative;top: 10px;">
				<table class="table table-hover">
					<thead>
						<tr style="color: #B3B3B3;">
							<td><input type="checkbox"  id="qx"/></td>
							<td>名称</td>
							<td>所有者</td>
							<td>公司座机</td>
							<td>公司网站</td>
						</tr>
					</thead>
					<tbody id="customerBody">
<%--						<tr>--%>
<%--							<td><input type="checkbox" /></td>--%>
<%--							<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='detail.jsp';">动力节点</a></td>--%>
<%--							<td>zhangsan</td>--%>
<%--							<td>010-84846003</td>--%>
<%--							<td>http://www.bjpowernode.com</td>--%>
<%--						</tr>--%>
<%--                        <tr class="active">--%>
<%--                            <td><input type="checkbox" /></td>--%>
<%--                            <td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='detail.jsp';">动力节点</a></td>--%>
<%--                            <td>zhangsan</td>--%>
<%--                            <td>010-84846003</td>--%>
<%--                            <td>http://www.bjpowernode.com</td>--%>
<%--                        </tr>--%>
					</tbody>
				</table>
			</div>
			
			<div style="height: 50px; position: relative;top: 30px;">
				<div id="customerPage">

				</div>

			</div>
			
		</div>
		
	</div>
</body>
</html>