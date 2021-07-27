<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
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

	<script type="text/javascript" src="jquery/bs_typeahead/bootstrap3-typeahead.min.js"></script>

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
		//自动补全
		$("#create-customerName").typeahead({
			source: function (query, process) {
				$.get(
						"workbench/transaction/getCustomerName.do",
						{ "name" : query },
						function (data) {
							//alert(data);
							//data[{客户名字1}{2}{3}...]


							process(data);
						},
						"json"
				);
			},
			delay: 100//延迟加载时间,单位毫秒
		});
		//定制字段
		$("#definedColumns > li").click(function(e) {
			//防止下拉菜单消失
	        e.stopPropagation();
	    });
		//页面加载完毕自动查询全部。并铺好页面
		pageList(1,2);
		//条件查询的搜索按钮
		$("#searchBtn").click(function () {

			$("#hidden-fullname").val($.trim($("#search-fullname").val()))
			$("#hidden-owner").val($.trim($("#search-owner").val()))
			$("#hidden-customerId").val($.trim($("#search-customerId").val()))
			$("#hidden-source").val($.trim($("#search-source").val()))
			$("#hidden-birth").val($.trim($("#search-birth").val()))

			pageList(1,2);

		})
		//增加联系人按钮。这里只是打开前铺垫owner
		$("#addBtn").click(function () {

			$.ajax({
				url:"workbench/contacts/getUserList.do",    //这里第一个/不要
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


					$("#createContactsModal").modal("show");//show 要加上引号

				}
			})

		})
		//增加联系人按钮里面的保存按钮
		$("#saveBtn").click(function () {
			$.ajax({
				url:"workbench/contacts/save.do",
				data:{
					"owner":$.trim($("#create-owner").val()),//这行代表着将下拉列表中选好的值传上去
					"source":$.trim($("#create-source").val()),
					"fullname":$.trim($("#create-fullname").val()),
					"appellation":$.trim($("#create-appellation").val()),
					"job":$.trim($("#create-job").val()),
					"mphone":$.trim($("#create-mphone").val()),
					"email":$.trim($("#create-email").val()),
					"birth":$.trim($("#create-birth").val()),

					"customerName":$.trim($("#create-customerName").val()),

					"description":$.trim($("#create-description").val()),
					"contactSummary":$.trim($("#create-contactSummary").val()),
					"nextContactTime":$.trim($("#create-nextContactTime").val()),
					"address":$.trim($("#create-address").val())

				},
				type:"post",
				dataType: "json",                                 //这里是你想要的数据类型
				success:function (data) {
					if(data.success){

						pageList(1,$("#contactsPage").bs_pagination('getOption', 'rowsPerPage'));

						$("#contactsForm")[0].reset();           //这行代码按照视频课中的做法，能清空窗口。
						$("#createContactsModal").modal("hide")
					}
					else {
						alert("添加联系人失败");
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
		$("#contactsBody").on("click",$("input[name=xz]"),function () {
			$("#qx").prop("checked",$("input[name=xz]").length==$("input[name=xz]:checked").length)
		})
		$("#editBtn").click(function () {
			var $xz=$("input[name=xz]:checked")
			if($xz.length==0){
				alert("请选择你要修改的联系人")
			}
			else  if($xz.length>1){
				alert("每次修改只能选择一个联系人")
			}
			else {
				var id=$xz.val()
				$.ajax({
					url:"workbench/contacts/getUserListAndContacts.do",
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
						{"uList":[{用户1}，{2}，{3}]，"c":{一个联系人}}
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
						$("#edit-id").val(data.c.id) //这个是从后台传递回来的id！！！！！！！！！！！！！！
						$("#edit-source").val(data.c.source)
						$("#edit-fullname").val(data.c.fullname)
						$("#edit-appellation").val(data.c.appellation)
						$("#edit-job").val(data.c.job)
						$("#edit-mphone").val(data.c.mphone)
						$("#edit-email").val(data.c.email)
						$("#edit-birth").val(data.c.birth)
						$("#edit-customerName").val(data.c.customerId)
						$("#edit-description").val(data.c.description)
						$("#edit-contactSummary").val(data.c.contactSummary)
						$("#edit-nextContactTime").val(data.c.nextContactTime)
						$("#edit-address").val(data.c.address)

						//所有的东西都写好后，显示出来模态窗口
						$("#editContactsModal").modal("show")

					}
				})


			}

		})
		$("#updateBtn").click(function () {
			//记住 添加操作和修改操作的步骤几乎一模一样。在实际开发过程中，也是先做添加操做，再做修改更新操作


			$.ajax({
				url:"workbench/contacts/update.do",
				data:{
					"id":$.trim($("#edit-id").val()),
					"owner":$.trim($("#edit-owner").val()),//这行代表着将下拉列表中选好的值传上去
					"source":$.trim($("#edit-source").val()),
					"fullname":$.trim($("#edit-fullname").val()),
					"appellation":$.trim($("#edit-appellation").val()),
					"job":$.trim($("#edit-job").val()),
					"mphone":$.trim($("#edit-mphone").val()),
					"email":$.trim($("#edit-email").val()),
					"birth":$.trim($("#edit-birth").val()),

					"customerName":$.trim($("#edit-customerName").val()),

					"description":$.trim($("#edit-description").val()),
					"contactSummary":$.trim($("#edit-contactSummary").val()),
					"nextContactTime":$.trim($("#edit-nextContactTime").val()),
					"address":$.trim($("#edit-address").val())
				},
				type:"post",
				dataType: "json",                                 //这里是你想要的数据类型
				success:function (data) {
					if(data.success){
						pageList($("#contactsPage").bs_pagination('getOption', 'currentPage')
								,$("#contactsPage").bs_pagination('getOption', 'rowsPerPage'));

						// pageList(1,2)//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1
						//$("#activityAddForm")[0].reset();           //这行代码按照视频课中的做法，再次打开添加的时候能清空窗口。
						$("#editContactsModal").modal("hide")
					}
					else {
						alert("修改联系人失败");
					}
				}
			})




		})
		//为删除按钮创建单击事件。支持批量删除
		$("#deleteBtn").click(function () {
			var $xz=$("input[name=xz]:checked")
			if($xz.length==0){
				alert("请选择需要删除的联系人")
			}else {
				if(confirm("确定删除选中的联系人吗？")){
					var param=""
					for(var i=0 ;i<$xz.length;i++){
						param += "id="+$($xz[i]).val()
						if(i<$xz.length-1){
							param += "&";       //这里拼接的是地址栏的参数。因为是参数。所以地址栏会自动在第一个参数前添加”？“
						}
					}
					//alert(param)
					$.ajax({
						url:"workbench/contacts/delete.do",
						data:param,          //因为这次是按照key=value&key=value  的形式传/!!!!!!!!!!！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！!!!1这里不要{}
						type:"post",     //删除操作，使用post
						dataType: "json",                                 //这里是你想要的数据类型
						success:function (data) {
							/*
                            data
                            {"success":true/false}
                             */
							if(data.success){
								pageList(1,$("#contactsPage").bs_pagination('getOption', 'rowsPerPage'));

								// pageList(1,2)

							}else {
								alert("删除联系人失败")
							}


						}
					})

				}

			}
		})


		
	});
	//函数！！！！
	//分页函数
	function pageList(pageNo,pageSize) {

		$("#search-fullname").val($.trim($("#hidden-fullname").val()))
		$("#search-owner").val($.trim($("#hidden-owner").val()))
		$("#search-customerId").val($.trim($("#hidden-customerId").val()))
		$("#search-source").val($.trim($("#hidden-source").val()))
		$("#search-birth").val($.trim($("#hidden-birth").val()))

		$("#qx").prop("checked",false) //checked记得加上引号！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！

		//alert("展现市场活动列表");
		//使用ajax局部刷新
		$.ajax({
			url:"workbench/contacts/pageList.do",
			data:{
				"pageNo":pageNo,
				"pageSize":pageSize,
				<%--"id":${}--%>//这里没有要id！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
				"owner":$.trim($("#search-owner").val()),
				"fullname":$.trim($("#search-fullname").val()),
				"customerId":$.trim($("#search-customerId").val()),
				"source":$.trim($("#search-source").val()),
				"birth":$.trim($("#search-birth").val())
			},
			type:"get",
			dataType: "json",
			success:function (data) {
				var html="";
				$.each(data.dataList,function (i,n) {
					html += '<tr class="active">';
					html += '<td><input type="checkbox" name="xz" value="'+n.id+'" /></td>';//这里要加上id！想明白为什么！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
					html += '<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href=\'workbench/contacts/detail.do?id='+n.id+'\';">'+n.fullname+'</a></td>';
					html += '<td>'+n.customerId+'</td>';
					//alert(n.customerId)
					html += '<td>'+n.owner+'</td>';
					html += '<td>'+n.source+'</td>';
					html += '<td>'+n.birth+'</td>';
					html += '</tr>';
				})
				$("#contactsBody").html(html);
				var totalPages=data.total%pageSize==0 ? data.total/pageSize:parseInt(data.total/pageSize)+1; //注意这里处理的parseInt
				//数据处理完毕后，结合分页插件，对前端展现分页信息
				$("#contactsPage").bs_pagination({
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

					<input type="hidden" id="hidden-fullname">
					<input type="hidden" id="hidden-customerId">
					<input type="hidden" id="hidden-owner">
					<input type="hidden" id="hidden-source">
					<input type="hidden" id="hidden-birth">


	
	<!-- 创建联系人的模态窗口 -->
	<div class="modal fade" id="createContactsModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" onclick="$('#createContactsModal').modal('hide');">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabelx">创建联系人</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" id="contactsForm" role="form">
					
						<div class="form-group">
							<label for="create-owner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-owner">

								</select>
							</div>
							<label for="create-source" class="col-sm-2 control-label">来源</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-source">
								  <option></option>
									<c:forEach items="${sourceList}" var="s">
										<option value="${s.text}">${s.value}</option>
									</c:forEach>
								</select>
							</div>
						</div>
						
						<div class="form-group">
							<label for="create-fullname" class="col-sm-2 control-label">姓名<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-fullname">
							</div>
							<label for="create-appellation" class="col-sm-2 control-label">称呼</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-appellation">
								  <option></option>
									<c:forEach items="${appellationList}" var="a">
										<option value="${a.text}">${a.value}</option>
									</c:forEach>
								</select>
							</div>
							
						</div>
						
						<div class="form-group">
							<label for="create-job" class="col-sm-2 control-label">职位</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-job">
							</div>
							<label for="create-mphone" class="col-sm-2 control-label">手机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-mphone">
							</div>
						</div>
						
						<div class="form-group" style="position: relative;">
							<label for="create-email" class="col-sm-2 control-label">邮箱</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-email">
							</div>
							<label for="create-birth" class="col-sm-2 control-label">生日</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-birth">
							</div>
						</div>
						
						<div class="form-group" style="position: relative;">
							<label for="create-customerName" class="col-sm-2 control-label">客户名称</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-customerName" placeholder="支持自动补全，输入客户不存在则新建">
							</div>
						</div>
						
						<div class="form-group" style="position: relative;">
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
	
	<!-- 修改联系人的模态窗口 -->
	<div class="modal fade" id="editContactsModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel1">修改联系人</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" role="form">

						<input type="hidden" id="edit-id">
						<div class="form-group">
							<label for="edit-owner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-owner">

								</select>
							</div>
							<label for="edit-source" class="col-sm-2 control-label">来源</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-source">
								  <option></option>
									<c:forEach items="${sourceList}" var="s">
										<option value="${s.text}">${s.value}</option>
									</c:forEach>
								</select>
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-fullname" class="col-sm-2 control-label">姓名<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-fullname" >
							</div>
							<label for="edit-appellation" class="col-sm-2 control-label">称呼</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-appellation">
								  <option></option>
									<c:forEach items="${appellationList}" var="a">
										<option value="${a.text}">${a.value}</option>
									</c:forEach>

								</select>
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-job" class="col-sm-2 control-label">职位</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-job" value="CTO">
							</div>
							<label for="edit-mphone" class="col-sm-2 control-label">手机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-mphone" >
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-email" class="col-sm-2 control-label">邮箱</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-email" >
							</div>
							<label for="edit-birth" class="col-sm-2 control-label">生日</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-birth">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-customerName" class="col-sm-2 control-label">客户名称</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-customerName" placeholder="支持自动补全，输入客户不存在则新建" >
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
					<button type="button" class="btn btn-primary"   id="updateBtn" data-dismiss="modal">更新</button>
				</div>
			</div>
		</div>
	</div>

	<div>
		<div style="position: relative; left: 10px; top: -10px;">
			<div class="page-header">
				<h3>联系人列表</h3>
			</div>
		</div>
	</div>
<%--	查询框--%>
	<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">
	
		<div style="width: 100%; position: absolute;top: 5px; left: 10px;">
		
			<div class="btn-toolbar" role="toolbar" style="height: 80px;">
				<form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">所有者</div>
				      <input class="form-control" type="text" id="search-owner" >
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">姓名</div>
				      <input class="form-control" type="text" id="search-fullname">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">客户名称</div>
				      <input class="form-control" type="text" id="search-customerId">
				    </div>
				  </div>
				  
				  <br>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">来源</div>
				      <select class="form-control" id="search-source" >
						  <option></option>
						  <c:forEach items="${sourceList}" var="s">
							  <option value="${s.text}">${s.value}</option>
						  </c:forEach>

						</select>
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">生日</div>
				      <input class="form-control" type="text" id="search-birth">
				    </div>
				  </div>
				  
				  <button type="button" id="searchBtn" class="btn btn-default">查询</button>
				  
				</form>
			</div>
			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 10px;">
				<div class="btn-group" style="position: relative; top: 18%;">
				  <button type="button" class="btn btn-primary" id="addBtn" ><span class="glyphicon glyphicon-plus"></span> 创建</button>
				  <button type="button" class="btn btn-default"  id="editBtn" ><span class="glyphicon glyphicon-pencil"></span> 修改</button>
				  <button type="button" class="btn btn-danger" id="deleteBtn"><span class="glyphicon glyphicon-minus"></span> 删除</button>
				</div>
			</div>
<%--			展示列表--%>
			<div style="position: relative;top: 20px;">
				<table class="table table-hover">
					<thead>
						<tr style="color: #B3B3B3;">
							<td><input type="checkbox" id="qx" /></td>
							<td>姓名</td>
							<td>客户名称</td>
							<td>所有者</td>
							<td>来源</td>
							<td>生日</td>
						</tr>
					</thead>
					<tbody id="contactsBody">

					</tbody>
				</table>
			</div>
			
			<div style="height: 50px; position: relative;top: 10px;">
				<div id="contactsPage">

				</div>
			</div>
			
		</div>
		
	</div>
</body>
</html>