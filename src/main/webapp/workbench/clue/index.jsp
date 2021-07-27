
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

<script type="text/javascript">

	$(function(){

		//页面加载完毕后 ，分页操作
		pageList(1,2);

		//全选操作
		$("#qx").click(function () {
			$("input[name=xz]").prop("checked",this.checked)  //这行表示：如果this。checked为true，那么给每一个类型为
															  //input且name=xz的标签赋值为checked

		})

		//反向全选操作
		$("#clueBody").on("click",$("input[name=xz]"),function () {
			$("#qx").prop("checked",$("input[name=xz]").length==$("input[name=xz]:checked").length)

		})

		$(".time").datetimepicker({                //这里使用$(".time")是class ，因为会多处用到这个事件插件，
			minView: "month",
			language:  'zh-CN',
			format: 'yyyy-mm-dd',
			autoclose: true,
			todayBtn: true,
			pickerPosition: "top-left"
		});

		//为创建按线索钮绑定事件。。
		/*
		在点击创建按钮之后，要弹出创建的模态窗口，但是模态窗口中的信息要处理完毕，才能被展示出来
		1.处理几个下拉列表，从数据字典中获得值。数据字典是在服务器缓存中的。当服务器一打开，就会执行监听器里面的初始化方法
		 并创建上下文域对象，application。这个方法里面还有sql 语句，所以是从数据库拿到了数据。放到了application中。只要你不关闭
		 服务器。这个application'就会存在。
		 ！！！！数据字典的处理是使用jstl标签去解决的
		2.但是不能将owner放进去。因为若是你在使用这个系统的过程中，添加了新的用户，但是弹出的所有者的列表中，不会显示出来。
		 因为他是缓存数据。没有再次与数据库交互所。

		而这个模态窗口里面由一个信息选项是 ！！！！——————所有者。
		在这个项目当中，见到所有者 要小心处理

		3. 所以这里的添加按钮里面的ajax其实是为了获得用户信息列表


		 */
		//点击创建按钮后，先获得所有者，再打开创建模块
		$("#addBtn").click(function () {
			$.ajax({
				url:"workbench/clue/getUserList.do",
				data:{
				},
				type:"get",
				dataType: "json",                                 //这里是你想要的数据类型
				success:function (data) {
					/*
					data[{用户1}{用户2}{用户3}{用户4}]       加载用户信息列表的时候不用考虑 返回值为true或者false！！！！！！！！！！！
					 */
					var html="<option></option>";
					var id="${user.id}"

					$.each(data,function (i,n) {

						if(n.id==id){//////////////疑问为什么这里 == 可以判断数据库中的字符串是否相等/////////////!!!!!!!!!!!!!!!!!
							html=html+" <option value=' "+n.id +" ' selected > "+n.name+" </option>"
						}

						else
							html +="<option value=' "+n.id +" ' > "+n.name+" </option>"
					})
					//这里不用判断if else ,因为这一步是点击菜单栏，在点击后添加所有者下拉列表的信息
					//小操作，几乎都不会失败。


					$("#create-owner").html(html);
					$("#createClueModal").modal("show");

				}
			})
		})


		//为保存按钮绑定事件，执行线索添加操作
		//一定在取值的时候要trim和val！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！1

		$("#saveBtn").click(function () {
			$.ajax({
				url:"workbench/clue/save.do",
				data:{
					"fullname":$.trim($("#create-fullname").val()),
					"appellation":$.trim($("#create-appellation").val()),
					"owner":$.trim($("#create-owner").val()),
					"company":$.trim($("#create-company").val()),
					"job":$.trim($("#create-job").val()),
					"email":$.trim($("#create-email").val()),
					"phone":$.trim($("#create-phone").val()),
					"website":$.trim($("#create-website").val()),
					"mphone":$.trim($("#create-mphone").val()),
					"state":$.trim($("#create-state").val()),
					"source":$.trim($("#create-source").val()),


					"description":$.trim($("#create-description").val()),
					"contactSummary":$.trim($("#create-contactSummary").val()),
					"nextContactTime":$.trim($("#create-nextContactTime").val()),
					"address":$.trim($("#create-address").val())

				},
				type:"post",
				dataType: "json",                                 //这里是你想要的数据类型
				success:function (data) {
					/*
					data
					{"data":true/false}
					*/
					if(data.success){
						pageList(1,$("#cluePage").bs_pagination('getOption', 'rowsPerPage'));
						$("#clueAddForm")[0].reset();
						$("#createClueModal").modal("hide")
						//成功后关闭模态窗口；，
						//刷新列表！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！111

					}
					else {
						alert("保存线索失败")
					}


				}
			})

		})
		//为搜索按钮绑定事件
		$("#searchBtn").click(function () {

			$("#hidden-fullname").val($.trim($("#search-fullname").val()))

			$("#hidden-company").val($.trim($("#search-company").val()))
			$("#hidden-phone").val($.trim($("#search-phone").val()))
			$("#hidden-source").val($.trim($("#search-source").val()))
			$("#hidden-owner").val($.trim($("#search-owner").val()))
			$("#hidden-mphone").val($.trim($("#search-mphone").val()))
			$("#hidden-state").val($.trim($("#search-state").val()))

			pageList(1,2);

		})
		//$("#editClueModal").modal("show")

//为修改按钮绑定事件
		$("#editBtn").click(function () {
				var $xz=$("input[name=xz]:checked")
				if($xz.length==0){
					alert("请选择你要修改的线索")
				}
				else  if($xz.length>1){
					alert("每次修改只能选择一个线索")
				}
				else {
					//这里只是得到了复选框的id，而id【代表了】一条线索的全部内容，并不是说，我们得到了我们所看到的复选框的那一小行信息。
					var id=$xz.val() /*注意这里：因为走到这一步，说明jquery对象只有一个元素。当你非常确定jquery只有
				                一个对象的时候。可以是value和val通用。否则只能遍历jquery数组，使用下标。
				                然后用value的到值
				                */
					$.ajax({
						url:"workbench/clue/getUserListAndClue.do",
						data:{
							"id":id,                           // 传递过去的被选中的活动的id!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
						},
						type:"get",
						dataType: "json",                                 //这里是你想要的数据类型
						success:function (data) {
							/*
                            data
                            用户对象
                            线索活动列表
                            {"uList":[{用户1}，{2}，{3}]，"c":{一条线索}}
                            */
							var html="<option></option>";

							$.each(data.uList,function (i,n) {
								if(data.c.owner==n.id){
									html += " <option value='"+n.id+" 'selected>"+n.name+"</option>"
								}
								else
									html += " <option value='"+n.id+"'>"+n.name+"</option>"
							})

							$("#edit-owner").html(html);//这一行已经有了用户的id

							$("#edit-id").val(data.c.id) //这个是从后台传递回来的线索的id，放到隐藏区域的id中！！！！！！！！！！！！！！

							$("#edit-company").val(data.c.company)
							$("#edit-appellation").val(data.c.appellation)
							$("#edit-fullname").val(data.c.fullname)
							$("#edit-job").val(data.c.job)
							$("#edit-email").val(data.c.email)

							$("#edit-phone").val(data.c.phone)
							$("#edit-website").val(data.c.website)
							$("#edit-fullname").val(data.c.fullname)
							$("#edit-mphone").val(data.c.mphone)
							$("#edit-state").val(data.c.state)

							$("#edit-source").val(data.c.source)
							$("#edit-description").val(data.c.description)
							$("#edit-contactSummary").val(data.c.contactSummary)
							$("#edit-nextContactTime").val(data.c.nextContactTime)
							$("#edit-address").val(data.c.address)



							//所有的东西都写好后，显示出来模态窗口
							$("#editClueModal").modal("show")

						}
					})
				}
			})

//为更新按钮绑定事件
		$("#updateBtn").click(function () {
			$.ajax({
				url:"workbench/clue/update.do",
				data:{
					"id":$.trim($("#edit-id").val()),//id为隐藏域中的id，是编辑窗口打开后才生成的id

					"owner":$.trim($("#edit-owner").val()),
					"company":$.trim($("#edit-company").val()),
					"appellation":$.trim($("#edit-appellation").val()),
					"fullname":$.trim($("#edit-fullname").val()),
					"job":$.trim($("#edit-job").val()),
					"email":$.trim($("#edit-email").val()),
					"phone":$.trim($("#edit-phone").val()),
					"website":$.trim($("#edit-website").val()),
					"mphone":$.trim($("#edit-mphone").val()),
					"state":$.trim($("#edit-state").val()),
					"source":$.trim($("#edit-source").val()),
					"description":$.trim($("#edit-description").val()),
					"contactSummary":$.trim($("#edit-contactSummary").val()),
					"nextContactTime":$.trim($("#edit-nextContactTime").val()),
					"address":$.trim($("#edit-address").val())

				},
				type:"post",
				dataType: "json",                                 //这里是你想要的数据类型
				success:function (data) {
					/*
					data
					{"data":true/false}
					 */
					if(data.success){
						pageList($("#cluePage").bs_pagination('getOption', 'currentPage')
								,$("#cluePage").bs_pagination('getOption', 'rowsPerPage'));
						$("#editClueModal").modal("hide")
						//成功后关闭模态窗口；，
						//刷新列表！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！111

					}
					else {
						alert("更新线索失败")
					}


				}
			})


		})
		//为删除按钮创建单击事件。支持批量删除
		$("#deleteBtn").click(function () {
			var $xz=$("input[name=xz]:checked")

			if($xz.length==0){
				alert("请选择需要删除的线索")
			}else {
				//url:http://localhost:8080/crm/workbench/clue/delete.do?id=xxx&id=xxx
				//肯定选了复选框，可能是一个，也可能是多个.这里的复选框是动态生成的，而且，选中了复选框就等于得到了该活动的id值
				//获取选中的复选框的id，作为参数上传到地址栏。
				//因为这里是多个id，即同一个参数名字，多个值。所以使用字符串拼接的方式。
				if(confirm("确定删除选中的线索吗？")){
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
						url:"workbench/clue/delete.do",
						data:param,          //因为这次是按照key=value&key=value  的形式传/!!!!!!!!!!！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！!!!1这里不要{}
						type:"post",     //删除操作，使用post
						dataType: "json",                                 //这里是你想要的数据类型
						success:function (data) {
							/*
                            data
                            {"success":true/false}
                             */
							if(data.success){
								pageList(1,$("#cluePage").bs_pagination('getOption', 'rowsPerPage'));

								// pageList(1,2)

							}else {
								alert("删除线索失败")
							}


						}
					})

				}

			}

		})


	});

	function pageList(pageNo,pageSize) {
		$("#search-fullname").val($.trim($("#hidden-fullname").val()))

		$("#search-company").val($.trim($("#hidden-company").val()))
		$("#search-phone").val($.trim($("#hidden-phone").val()))
		$("#search-source").val($.trim($("#hidden-source").val()))
		$("#search-owner").val($.trim($("#hidden-owner").val()))
		$("#search-mphone").val($.trim($("#hidden-mphone").val()))
		$("#search-state").val($.trim($("#hidden-state").val()))

		$("#qx").prop("checked",false);

		$.ajax({
			url:"workbench/clue/pageList.do",
			data:{
				"pageNo":pageNo,
				"pageSize":pageSize,
				"fullname":$.trim($("#search-fullname").val()),
				"company":$.trim($("#search-company").val()),
				"phone":$.trim($("#search-phone").val()),
				"source":$.trim($("#search-source").val()),
				"owner":$.trim($("#hidden-owner").val()),
				"mphone":$.trim($("#search-mphone").val()),
				"state":$.trim($("#search-state").val())
			},
			type:"get",
			dataType: "json",                                 //这里是你想要的数据类型
			success:function (data) {
				//{"total":100,"dataList":[{线索1},{线索2},{线索3}，.....]}
				var html="";

				$.each(data.dataList,function (i,n) {

				html += '<tr class="active">'
					//name="xz" 是个每个查询出来的线索的复选框起名字
				html += '<td><input type="checkbox" name="xz" value="'+n.id+'" /></td>'
				html += '<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href=\'workbench/clue/detail.do?id='+n.id+'\';">'+n.fullname+n.appellation+'</a></td>'
				html += '<td>'+n.company+'</td>'
				html += '<td>'+n.phone+'</td>'
				html += '<td>'+n.mphone+'</td>'
				html += '<td>'+n.source+'</td>'
				html += '<td>'+n.owner+'</td>'//这里的owner还可以得到owner的中文。不用在sql中实现得到！！！！！！！！！！！！！！！！！！！！！！！！！！！！~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
				html += '<td>'+n.state+'</td>'
				html += '</tr>'

				})
				$("#clueBody").html(html);

				var totalPages=data.total%pageSize==0 ? data.total/pageSize:parseInt(data.total/pageSize)+1;

				//下面的#cluePage是最下面的模块，其展示的是分页的动画
				$("#cluePage").bs_pagination({
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
    <%--隐藏区域，用于查询时候，对跳转页面的体验的优化--%>
    <input type="hidden" id="hidden-fullname">


    <input type="hidden" id="hidden-company">
    <input type="hidden" id="hidden-phone">
    <input type="hidden" id="hidden-source">
    <input type="hidden" id="hidden-owner">
    <input type="hidden" id="hidden-mphone">
    <input type="hidden" id="hidden-state">





	<!-- 创建线索的模态窗口 -->
	<div class="modal fade" id="createClueModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 90%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel">创建线索</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" role="form" id="clueAddForm">
					
						<div class="form-group">
							<label for="create-owner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-owner">

								</select>
							</div>
							<label for="create-company" class="col-sm-2 control-label">公司<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-company">
							</div>
						</div>
						
						<div class="form-group">
							<label for="create-appellation" class="col-sm-2 control-label">称呼</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-appellation">
								  <option></option>
								 <c:forEach items="${appellationList}" var="a">
<%--									 value 是此处字典七大类型中每一大类的值。是数据库中的列名--%>
									 <option value="${a.value}">${a.text}</option>
								 </c:forEach>

								</select>
							</div>
							<label for="create-fullname" class="col-sm-2 control-label">姓名<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-fullname">
							</div>
						</div>
						
						<div class="form-group">
							<label for="create-job" class="col-sm-2 control-label">职位</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-job">
							</div>
							<label for="create-email" class="col-sm-2 control-label">邮箱</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-email">
							</div>
						</div>
						
						<div class="form-group">
							<label for="create-phone" class="col-sm-2 control-label">公司座机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-phone">
							</div>
							<label for="create-website" class="col-sm-2 control-label">公司网站</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-website">
							</div>
						</div>
						
						<div class="form-group">
							<label for="create-mphone" class="col-sm-2 control-label">手机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-mphone">
							</div>
							<label for="create-state" class="col-sm-2 control-label">线索状态</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-state">
								  <option></option>
									<c:forEach items="${clueStateList}" var="c">
										<option value="${c.value}">${c.text}</option>
									</c:forEach>

								</select>
							</div>
						</div>
						
						<div class="form-group">
							<label for="create-source" class="col-sm-2 control-label">线索来源</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-source">
								  <option></option>
									<c:forEach items="${sourceList}" var="s">
										<option value="${s.value}">${s.text}</option>
									</c:forEach>
								</select>
							</div>
						</div>
						

						<div class="form-group">
							<label for="create-description" class="col-sm-2 control-label">线索描述</label>
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
					<button type="button" class="btn btn-primary" id="saveBtn">保存</button>
				</div>
			</div>
		</div>
	</div>
	
	<!-- 修改线索的模态窗口 -->
	<div class="modal fade" id="editClueModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 90%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">修改线索</h4>
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
							<label for="edit-company" class="col-sm-2 control-label">公司<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-company" value="动力节点">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-appellation" class="col-sm-2 control-label">称呼</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-appellation">
									<c:forEach items="${appellationList}" var="a">
										<%-- value 是此处字典七大类型中每一大类的值。是数据库中的列名--%>
										<option value="${a.value}">${a.text}</option>
									</c:forEach>
								</select>
							</div>
							<label for="edit-fullname" class="col-sm-2 control-label">姓名<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-fullname" value="李四">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-job" class="col-sm-2 control-label">职位</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-job" >
							</div>
							<label for="edit-email" class="col-sm-2 control-label">邮箱</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-email" >
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-phone" class="col-sm-2 control-label">公司座机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-phone" >
							</div>
							<label for="edit-website" class="col-sm-2 control-label">公司网站</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-website" >
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-mphone" class="col-sm-2 control-label">手机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-mphone" >
							</div>
							<label for="edit-state" class="col-sm-2 control-label">线索状态</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-state">
									<c:forEach items="${clueStateList}" var="c">
										<option value="${c.value}">${c.text}</option>
									</c:forEach>
								</select>
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-source" class="col-sm-2 control-label">线索来源</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-source">
									<c:forEach items="${sourceList}" var="s">
										<option value="${s.value}">${s.text}</option>
									</c:forEach>
								</select>
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
									<input type="text" class="form-control time" id="edit-nextContactTime" >
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
				<h3>线索列表</h3>
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
				      <input class="form-control" type="text" id="search-fullname">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">公司</div>
				      <input class="form-control" type="text" id="search-company">
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
				      <div class="input-group-addon">线索来源</div>
					  <select class="form-control" id="search-source">
					  	  <option></option>
						  <c:forEach items="${sourceList}" var="s">
							  <option value="${s.value}">${s.text}</option>
						  </c:forEach>
					  </select>
				    </div>
				  </div>
				  
				  <br>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">所有者</div>
				      <input class="form-control" type="text" id="search-owner">
				    </div>
				  </div>
				  
				  
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">手机</div>
				      <input class="form-control" type="text" id="search-mphone">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">线索状态</div>
					  <select class="form-control" id="search-state">
					  	<option></option>
						  <c:forEach items="${clueStateList}" var="c">
							  <option value="${c.value}">${c.text}</option>
						  </c:forEach>
					  </select>
				    </div>
				  </div>

				  <button type="button" id="searchBtn" class="btn btn-default">查询</button>
				  
				</form>
			</div>
			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 40px;">
				<div class="btn-group" style="position: relative; top: 18%;">
				  <button type="button" class="btn btn-primary" id="addBtn"><span class="glyphicon glyphicon-plus"></span> 创建</button>
				  <button type="button" class="btn btn-default" id="editBtn"><span class="glyphicon glyphicon-pencil"></span> 修改</button>
				  <button type="button" class="btn btn-danger" id="deleteBtn"><span class="glyphicon glyphicon-minus"></span> 删除</button>
				</div>
				
				
			</div>
			<div style="position: relative;top: 50px;">
				<table class="table table-hover">
					<thead>
						<tr style="color: #B3B3B3;">
							<td><input type="checkbox"  id="qx"/></td>
							<td>名称</td>
							<td>公司</td>
							<td>公司座机</td>
							<td>手机</td>
							<td>线索来源</td>
							<td>所有者</td>
							<td>线索状态</td>
						</tr>
					</thead>
					<tbody id="clueBody">
<%--				r>--%>
<%--					<td><input type="checkbox" /></td>--%>
<%--												&lt;%&ndash;超链接就像一个ajax，等于发起一个.do的请求。下一步就是在web.xml中设置地址&ndash;%&gt;--%>
<%--					<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='workbench/clue/detail.do?id=90259f9d205c42059fc19b039dcf1ca6';">马云先生</a></td>--%>
<%--					<td>动力节点</td>--%>
<%--					<td>010-84846003</td>--%>
<%--					<td>12345678901</td>--%>
<%--					<td>广告</td>--%>
<%--					<td>zhangsan</td>--%>
<%--					<td>已联系</td>--%>
<%--				tr>--%>
<%--    			<tr class="active">--%>
<%--    			    <td><input type="checkbox" /></td>--%>
<%--    			    <td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='workbench/clue/detail.jsp';">李四先生</a></td>--%>
<%--    			    <td>动力节点</td>--%>
<%--    			    <td>010-84846003</td>--%>
<%--    			    <td>12345678901</td>--%>
<%--    			    <td>广告</td>--%>
<%--    			    <td>zhangsan</td>--%>
<%--    			    <td>已联系</td>--%>
<%--    			</tr>--%>
					</tbody>
				</table>
			</div>
			
			<div style="height: 50px; position: relative;top: 60px;">


			</div>

			<div style="height: 50px; position: relative;top: 30px;">
				<div id="cluePage">

				</div>
			</div>
			
		</div>
		
	</div>
</body>
</html>