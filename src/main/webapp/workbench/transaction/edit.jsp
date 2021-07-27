<%@ page import="java.util.Map" %>
<%@ page import="java.util.Set" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
	String basePath =request.getScheme() +"://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath()+ "/";
	Map<String,String> pMap= (Map<String, String>) application.getAttribute("pMap");
	Set<String> set=pMap.keySet();
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

	<script type="text/javascript" src="jquery/bs_typeahead/bootstrap3-typeahead.min.js"></script>

	<script type="text/javascript">

		var json={
			<%
             for(String key :set){
                  String value=pMap.get(key);
            %>
			"<%=key%>":<%=value%>,//这里最后一个，逗号会自动处理掉。因为我们上来就定义了var json。来提示这是一个json对象
			<%
            }
            %>

		};

		$(function () {
			//日历插件
			$(".time1").datetimepicker({                //这里使用$(".time")是class ，因为会多处用到这个事件插件，
				minView: "month",
				language:  'zh-CN',
				format: 'yyyy-mm-dd',
				autoclose: true,
				todayBtn: true,
				pickerPosition: "bottom-left"
			});
			$(".time2").datetimepicker({                //这里使用$(".time")是class ，因为会多处用到这个事件插件，
				minView: "month",
				language:  'zh-CN',
				format: 'yyyy-mm-dd',
				autoclose: true,
				todayBtn: true,
				pickerPosition: "top-left"
			});

			//阶段的选择决定了可能性的多少
			$("#edit-stage").change(function () {     //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

				//alert("qqqqqqqq");
				var  stage=$("#edit-stage").val();


				var  possibility =json[stage];//json.key的形式
				//alert(possibility)

				$("#edit-possibility").val(possibility);

			})

			$("#aname").keydown(function (event) {
				if(event.keyCode==13){
					$.ajax({
						url:"workbench/transaction/getActivityByName.do",//这里是查询的全部市场活动。当然这里也可以按照需求，只查询与线索相关的活动。
						data:{
							"aname":$.trim($("#aname").val())

						},
						type:"get",
						dataType: "json",                                 //这里是你想要的数据类型
						success:function (data) {
							/*
                            data[{活动1}{2}{3}]
                            因为这里是铺表，所以不能去判断success。是必须成功的事情。
                             */
							var html=""

							$.each(data,function (i,n) {

								html += '<tr>'
								html += '<td><input type="radio"   value="'+n.id+'"  name="xz" /></td>'//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
								html += '<td id="'+n.id+'">'+n.name+'</td>'
								html += '<td>'+n.startDate+'</td>'
								html += '<td>'+n.endDate+'</td>'
								html += '<td>'+n.owner+'</td>'
								html += '</tr>'
							})

							$("#activitySearchBody").html(html)

						}
					})
					return false;
				}


			})

			$("#submitActivityBtn").click(function () {

				//将活动的id放到隐藏区域中
				var  $xz= $("input[name=xz]:checked")
				var  id=$xz.val()//这里取得是 value的值
				//点击活动的提交按钮，将市场活动的名字文本值铺上
				var  name=$("#"+id).html()//html取的是标签对中的值
				//alert(name)
				$("#activityName").val(name)

				//alert(id)
				$("#activityId").val(id)

				//关闭模态窗口.....!!!!这里可以不写!.因为  data-dismiss="modal"!   点击这个按钮后，按钮里面自动写了这个关闭 !!!!!!!!!!!!!!!!!!!!!!!!!!!
				//$("#findMarketActivity").modal("hidden");

			})

			$("#cname").keydown(function (event) {
				if(event.keyCode==13){
					$.ajax({
						url:"workbench/transaction/getContactsByName.do",//这里是查询的全部市场活动。当然这里也可以按照需求，只查询与线索相关的活动。
						data:{
							"cname":$.trim($("#cname").val())

						},
						type:"get",
						dataType: "json",                                 //这里是你想要的数据类型
						success:function (data) {
							/*
                            data[{联系人1}{2}{3}]
                            因为这里是铺表，所以不能去判断success。是必须成功的事情。
                             */
							var html=""

							$.each(data,function (i,n) {
								html += '<tr>'
								html += '<td><input type="radio" value="'+n.id+'" name="xz"/></td>'
								html += '<td id="'+n.id+'">'+n.fullname+'</td>'
								html += '<td>'+n.email+'</td>'
								html += '<td>'+n.mphone+'</td>'
								html += '</tr>'


							})

							$("#contactsSearchBody").html(html)

						}
					})
					return false;
				}


			})

			$("#submitContactsBtn").click(function () {

				//将活动的id放到隐藏区域中
				var  $xz= $("input[name=xz]:checked")
				var  id=$xz.val()//这里取得是 value的值
				//点击活动的提交按钮，将市场活动的名字文本值铺上
				var  name=$("#"+id).html()//html取的是标签对中的值
				//alert(name)
				$("#contactsName").val(name)

				//alert(id)
				$("#contactsId").val(id)

				//关闭模态窗口.....!!!!这里可以不写!.因为  data-dismiss="modal"!   点击这个按钮后，按钮里面自动写了这个关闭 !!!!!!!!!!!!!!!!!!!!!!!!!!!
				//$("#findMarketActivity").modal("hidden");

			})

			//更新按钮
			$("#updateBtn").click(function () {
				//$("#tranForm").submit();
				/*当这里再使用form表单提交的时候。会出现如果你不改变那两个放大镜的值。即
				市场活动源和联系人的时候。他不会触发按钮单击事件，那么市场活动和联系人的隐藏就没有被赋值。
				就会导致原本有的值被覆盖为null
				 */
				$.ajax({
					url:"workbench/transaction/update.do",
					data:{
				"id":"${t.id}",
				"owner":$.trim($("#edit-owner").val()),
				"money":$.trim($("#edit-money").val()),
				"name":$.trim($("#edit-name").val()),
				"expectedDate":$.trim($("#edit-expectedDate").val()),

				"customerName":$.trim($("#edit-customerName").val()),

				"stage":$.trim($("#edit-stage").val()),
				"type":$.trim($("#edit-type").val()),
				"source":$.trim($("#edit-source").val()),

				"activityId":$.trim($("#activityId").val()),
				"contactsId":$.trim($("#contactsId").val()),

				"description":$.trim($("#edit-description").val()),
				"contactSummary":$.trim($("#edit-contactSummary").val()),
				"nextContactTime":$.trim($("#edit-nextContactTime").val())
					},
					type:"get",
					dataType: "json",                                 //这里是你想要的数据类型
					success:function (data) {
						if(data.success){
							//response.sendRedirect(request.getContextPath()+"/workbench/transaction/index.jsp")

							alert("更新交易成功")
							window.location.reload();
						}
						else {
							alert("更新交易失败")
						}
					}
				})
			})



		});





	</script>

</head>
<body>

	<!-- 查找市场活动 -->	
	<div class="modal fade" id="findMarketActivity" role="dialog">
		<div class="modal-dialog" role="document" style="width: 80%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">查找市场活动</h4>
				</div>
				<div class="modal-body">
					<div class="btn-group" style="position: relative; top: 18%; left: 8px;">
						<form class="form-inline" role="form">
						  <div class="form-group has-feedback">
						    <input type="text" class="form-control" style="width: 300px;" id="aname" placeholder="请输入市场活动名称，支持模糊查询">
						    <span class="glyphicon glyphicon-search form-control-feedback"></span>
						  </div>
						</form>
					</div>
					<table id="activityTable4" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
						<thead>
							<tr style="color: #B3B3B3;">
								<td></td>
								<td>名称</td>
								<td>开始日期</td>
								<td>结束日期</td>
								<td>所有者</td>
							</tr>
						</thead>
						<tbody id="activitySearchBody">


						</tbody>
					</table>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
					<button type="button" class="btn btn-primary"  data-dismiss="modal" id="submitActivityBtn">提交</button>
				</div>
			</div>
		</div>
	</div>

	<!-- 查找联系人 -->	
	<div class="modal fade" id="findContacts" role="dialog">
		<div class="modal-dialog" role="document" style="width: 80%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">查找联系人</h4>
				</div>
				<div class="modal-body">
					<div class="btn-group" style="position: relative; top: 18%; left: 8px;">
						<form class="form-inline" role="form">
						  <div class="form-group has-feedback">
						    <input type="text" class="form-control"  id="cname" style="width: 300px;" placeholder="请输入联系人名称，支持模糊查询">
						    <span class="glyphicon glyphicon-search form-control-feedback"></span>
						  </div>
						</form>
					</div>
					<table id="activityTable" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
						<thead>
							<tr style="color: #B3B3B3;">
								<td></td>
								<td>名称</td>
								<td>邮箱</td>
								<td>手机</td>
							</tr>
						</thead>
						<tbody id="contactsSearchBody">

						</tbody>
					</table>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
					<button type="button" class="btn btn-primary" data-dismiss="modal" id="submitContactsBtn">提交</button>
				</div>
			</div>
		</div>
	</div>

	<div style="position: relative; top: 45px; left: 3px;">
		<a href="javascript:void(0);" onclick="window.history.back();"><span class="glyphicon glyphicon-arrow-left" style="font-size: 20px; color: #DDDDDD"></span></a>
	</div>
	
<%--	--%>
	<div style="position:  relative; left: 30px;">
		<h3>更新交易</h3>
	  	<div style="position: relative; top: -40px; left: 70%;">
			<button type="button" class="btn btn-primary" id="updateBtn" >更新</button>
			<button type="button" class="btn btn-default">取消</button>
		</div>
		<hr style="position: relative; top: -40px;">
	</div>
	<form  action="workbench/transaction/update.do" id="tranForm"class="form-horizontal" role="form" style="position: relative; top: -30px;">
		<div class="form-group">
			<label for="edit-owner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<select class="form-control" id="edit-owner" name="owner"><%--name属性添加在这里！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！1	--%>
					<option></option>
					<c:forEach items="${uList}" var="u">
						<option value="${u.id}" ${t.owner eq u.name ? "selected":""}>${u.name}</option> <%--这里的t的owner'是被处理过的。他实际上是中文名字！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！	--%>
					</c:forEach>
				</select>
			</div>
			<label for="edit-money" class="col-sm-2 control-label">金额</label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="edit-money" value="${t.money}" name="money">
			</div>
		</div>
		
		<div class="form-group">
			<input type="hidden" name="id" value="${t.id}">
			<label for="edit-name" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="edit-name"  value="${t.name}" name="name">
			</div>
			<label for="edit-expectedDate" class="col-sm-2 control-label">预计成交日期<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control time1" id="edit-expectedDate" value="${t.expectedDate}" name="expectedDate">
			</div>
		</div>
		
		<div class="form-group">
			<label for="edit-customerName" class="col-sm-2 control-label">客户名称<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="edit-customerName" value="${t.customerId}" name="customerName" placeholder="支持自动补全，输入客户不存在则新建">
			</div>
			<label for="edit-stage" class="col-sm-2 control-label">阶段<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
			  <select class="form-control" id="edit-stage" name="stage">
			  	<option></option>
				  <c:forEach items="${stageList}" var="s">
					  <option value="${s.value}"  ${t.stage eq  s.value ? "selected":""}>${s.text}</option>
				  </c:forEach>

			  </select>
			</div>
		</div>
		
		<div class="form-group">
			<label for="edit-type" class="col-sm-2 control-label">类型</label>
			<div class="col-sm-10" style="width: 300px;">
				<select class="form-control" id="edit-type" name="type">
				  <option></option>
					<c:forEach items="${transactionTypeList}" var="tt">
						<option value="${tt.value}" ${t.type eq  tt.value ? "selected":""}>${tt.text}</option>
					</c:forEach>

				</select>
			</div>
			<label for="edit-possibility" class="col-sm-2 control-label">可能性</label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="edit-possibility" value="${t.possibility}">
			</div>
		</div>
		
		<div class="form-group">
			<label for="edit-source" class="col-sm-2 control-label">来源</label>
			<div class="col-sm-10" style="width: 300px;">
				<select class="form-control" id="edit-source" name="source">
				  <option></option>
					<c:forEach items="${sourceList}" var="s">
						<option value="${s.value}" ${t.source eq  s.value ? "selected":""}>${s.text}</option>
					</c:forEach>
				</select>
			</div>
			<label for="activityName" class="col-sm-2 control-label">市场活动源&nbsp;&nbsp;<a href="#" id="openSearchActivityModalBtn" data-toggle="modal" data-target="#findMarketActivity"><span class="glyphicon glyphicon-search"></span></a></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="activityName" value="${t.activityId}" placeholder="点击放大镜搜索" readonly><%--	这里的 ${t.activityId}已经做过处理，显示的是中文	--%>
				<input type="hidden" id="activityId"  name="activityId" value="${t1.activityId}">
			</div>
		</div>
<%--		--%>
		<div class="form-group">
			<label for="contactsName" class="col-sm-2 control-label">联系人名称&nbsp;&nbsp;<a href="#" data-toggle="modal" data-target="#findContacts"><span class="glyphicon glyphicon-search"></span></a></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="contactsName" value="${t.contactsId}" placeholder="点击放大镜搜索" readonly>
				<input type="hidden" id="contactsId" name="contactsId" value="${t1.contactsId}">
			</div>
		</div>
		
		<div class="form-group">
			<label for="edit-description" class="col-sm-2 control-label">描述</label>
			<div class="col-sm-10" style="width: 70%;">
				<textarea class="form-control" rows="3" id="edit-description" name="description">${t.description}</textarea>
			</div>
		</div>
		
		<div class="form-group">
			<label for="edit-contactSummary" class="col-sm-2 control-label">联系纪要</label>
			<div class="col-sm-10" style="width: 70%;">
				<textarea class="form-control" rows="3" id="edit-contactSummary" name="contactSummary">${t.contactSummary}</textarea>
			</div>
		</div>
		
		<div class="form-group">
			<label for="edit-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control time2" id="edit-nextContactTime" name="nextContactTime" value="${t.nextContactTime}">
			</div>
		</div>
		
	</form>
</body>
</html>