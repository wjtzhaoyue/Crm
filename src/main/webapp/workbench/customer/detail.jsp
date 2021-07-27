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
	//这个页面拥有request区域中的customer对象c，是处理过的，其owner是中文~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

	//默认情况下取消和保存按钮是隐藏的
	var cancelAndSaveBtnDefault = true;
	
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
//显示备注里面的红色图标
		$("#remarkBody").on("mouseover",".remarkDiv",function(){
			$(this).children("div").children("div").show();
		})
		$("#remarkBody").on("mouseout",".remarkDiv",function(){
			$(this).children("div").children("div").hide();
		})

		$("#remark").focus(function(){
			if(cancelAndSaveBtnDefault){
				//设置remarkDiv的高度为130px
				$("#remarkDiv").css("height","130px");
				//显示
				$("#cancelAndSaveBtn").show("2000");
				cancelAndSaveBtnDefault = false;
			}
		});
		
		$("#cancelBtn").click(function(){
			//显示
			$("#cancelAndSaveBtn").hide();
			//设置remarkDiv的高度为130px
			$("#remarkDiv").css("height","90px");
			cancelAndSaveBtnDefault = true;
		});
		
		$(".remarkDiv").mouseover(function(){
			$(this).children("div").children("div").show();
		});
		
		$(".remarkDiv").mouseout(function(){
			$(this).children("div").children("div").hide();
		});
		
		$(".myHref").mouseover(function(){
			$(this).children("span").css("color","red");
		});
		
		$(".myHref").mouseout(function(){
			$(this).children("span").css("color","#E6E6E6");
		});
//页面加载完毕，调用写好的函数，展现与该客户相关的所有备注信息
		showRemarkList()
//页面加载完毕，调用写好的函数，展现与该客户相关的所有交易信息
		showTranList()
//为保存按钮添加操作
		$("#remarkBtn").click(function () {

			var content=$("#remark").val();//这里仍旧是textarea 但是因为textarea特殊，将其按照val来取值。这一点要记住
			$.ajax({
				url:"workbench/customer/saveRemark.do",
				data:{      "noteContent":$.trim(content),
					"customerId" :"${c.id}"// js中使用EL表达式必须加上双引号
				},
				type:"post",
				dataType: "json",                                 //这里是你想要的数据类型
				success:function (data) {
					//data
					//{"success":true/fales，"cr":{一条备注信息整体}
					if(data.success){
						//添加成功后，把文本域中的内容清空掉
						$("#remark").val("");

						//添加成功，在textarea上方添加一个div
						var html="";
						html += '<div id='+data.cr.id+' class="remarkDiv" style="height: 60px;">';
						html += '<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;"> <div style="position: relative; top: -40px; left: 40px;" >';
						html += '<h5 id="e'+data.cr.id+'">'+data.cr.noteContent+'</h5>';
						//上面的e 是随便拼接的，只是为了区分id。学会这种方法。
						html += '<font color="gray">客户</font> <font color="gray">-</font> <b>${c.name}</b> <small style="color: gray;" id="s'+data.cr.id+'"> '+(data.cr.createTime)+' 由'+(data.cr.createBy)+'</small>';
						html += '<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">';
						html += '<a class="myHref" href="javascript:void(0);" onclick="editRemark(\''+data.cr.id+'\')"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #FF0000;"></span></a>';//这里是设置那连个图标的。由 这句话中的class="glyphicon glyphicon-edit" ——后面的edit可以设置为别的，就是另外的图标。这是bootstrap的功能
						html += '&nbsp;&nbsp;&nbsp;&nbsp;';
						html += '<a class="myHref" href="javascript:void(0);" onclick="deleteRemark(\''+data.cr.id+'\')"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #FF0000;"></span></a>';
						html += '</div>';
						html += '</div>';
						html += '</div>';

						$("#remarkDiv").before(html)

					}else {
						alert("添加备注失败")
					}


				}
			})


		})
//备注的修改后的保存操作
		$("#updateRemarkBtn").click(function () {
			//这里由于下面还要使用id，所以将其放到ajax外面。若是放到ajax里面，写两遍一摸一样的显得麻烦
			var id=$("#remarkId").val();
			$.ajax({
				url:"workbench/customer/updateRemark.do",
				data:{      "id":id,
					"noteContent":$.trim($("#noteContent").val())// 这里是你传递的数据
				},
				type:"post",
				dataType: "json",                                 //这里是你想要的数据类型
				success:function (data) {
					//data
					//{"success":true/false,"cr":{备注信息整体}
					if(data.success){
						//修改成功，
						//根据返回来的数据，更新展现出来的备注信息。

						//下面的更新操作全部是按照已有的备注的div的内容去传值的

						//这里是展示更新后的备注信息到div
						//是给动态生成的那些div更改信息。！！！！！！！！！！！！！！！！！！！！！！！！！！！1
						$("#e"+id).html(data.cr.noteContent)//这里是对h5标签对里面的信息操作，所以使用html
						// <small style="color: gray;" id="s'+n.id+'"> '+(n.editFlag==0?n.createTime:n.editTime)+' 由'+(n.editFlag==0?n.createBy:n.editBy)+'</small>';
						//将上面的small里面的信息更改!!。small也是标签对!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
						$("#s"+id).html(data.cr.editTime+" 由"+data.cr.editBy)

						//更改信息后，关闭模态窗口
						$("#editRemarkModal").modal("hide")

					}else {
						alert("修改备注失败")
					}
				}
			})

		})
//展示联系人列表
		showContactsList();
//新建联系人
		$("#newContacts").click(function () {
			//使用之前写过的
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
							html=html+" <option value='"+n.id +" ' selected > "+n.name+" </option>"
						}

						else
							html +="<option value='"+n.id +" ' > "+n.name+" </option>"
					})


					$("#create-owner").html(html);


					//$("#createContactsModal").modal("show");//show 要加上引号

				}
			})

		})
//保存联系人
		$("#saveContacts").click(function () {
			//$("#tranForm").submit();//这里使用form表单提交效果不好，前端收不到反馈。
			$.ajax({
				url:"workbench/customer/saveContacts.do",
				data:{
					"owner":$.trim($("#create-owner").val()),
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
					"address":$.trim($("#create-address1").val())

				},
				type:"get",
				dataType: "json",                                 //这里是你想要的数据类型
				success:function (data) {
					if(data.success){

						window.location.reload();
					}
					else{
						alert("添加联系人失败")
					}
				}
			})

		})
//最上面的编辑里面的更新按钮
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
						// pageList(1,2)//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1
						//$("#activityAddForm")[0].reset();           //这行代码按照视频课中的做法，再次打开添加的时候能清空窗口。
						//$("#editCustomerModal").modal("hide")
						window.location.reload();
					}
					else {
						alert("修改客户信息失败");
					}
				}
			})




		})


	});

//函数

//展示所有备注
	function showRemarkList() {
		$.ajax({
			url:"workbench/customer/getRemarkListByCid.do",
			data:{       "customerId":"${c.id}"             //此处注意是EL表达式 。在js中使用el表达式必须加上“”  。此处的a是ActivityCOntroller类中的的detail方法的值。是一个活动对象。将其放在了request区域中          // 这里是你传递的数据!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
			},
			type:"get",
			dataType: "json",                                 //这里是你想要的数据类型
			success:function (data) {
				//data
				// [{备注1} {备注2}.....]
				var html="";

				$.each(data,function (i,n) {
					//关于字符串拼接。因为最原本的里面用的“”双引号比较多，所以在拼接的时候选择在最外面添加单引号
					//下面的这个  $ {c.name} 是从request区域中获得的。.请求转发的区域中
					//

					html += '<div id='+n.id+' class="remarkDiv" style="height: 60px;">';
					html += '<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;"> <div style="position: relative; top: -40px; left: 40px;" >';
					html += '<h5 id="e'+n.id+'">'+n.noteContent+'</h5>';
					//下面给加的id，为了方便得到活动的名称，更新这个过程中，只能改备注信息。其他的活动名称什么的都不变。给id拼接了个s
					html += '<font color="gray">客户</font> <font color="gray">-</font> <b>${c.name}</b> <small style="color: gray;" id="s'+n.id+'"> '+(n.editFlag==0?n.createTime:n.editTime)+' 由'+(n.editFlag==0?n.createBy:n.editBy)+'</small>';
					html += '<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">';
					html += '<a class="myHref" href="javascript:void(0);" onclick="editRemark(\''+n.id+'\')"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #FF0000;"></span></a>';//这里是设置那连个图标的。由 这句话中的class="glyphicon glyphicon-edit" ——后面的edit可以设置为别的，就是另外的图标。这是bootstrap的功能
					html += '&nbsp;&nbsp;&nbsp;&nbsp;';
					html += '<a class="myHref" href="javascript:void(0);" onclick="deleteRemark(\''+n.id+'\')"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #FF0000;"></span></a>';
					//javascript:void(0) 表示禁止使用超链接
					/*
					之所以是在动态生成的图标中绑定click方法，是因为。若是我们使用id的方式，因为是动态生成的。这样的话，
					每个市场活动的评论的id都一样了。导致删除的时候会出错。
					*/
					html += '</div>';
					html += '</div>';
					html += '</div>';
				})

				//下面使用的before 是在思考之后使用的
				/*
				思考如下：如果直接在 ”大备注”上添加id，然后使用html。那么会覆盖掉“大备注” 。之前都是这么做的，
				         那是因为里面都是空的，不存在覆盖的情况。
				所以做法有两种。1. 是在“大备注”下面写一个空的div，然后使用id和html。这样就不会覆盖掉大备注
				               2. 使用append或者before。此处的做法是使用了before
				 */
				$("#remarkDiv").before(html)
			}
		})

	}
//编辑备注窗口前的准备。
	function editRemark(id) {
		//alert(id)

		//将编辑的模态窗口的隐藏域中的id进行赋值!!!!!!!!!!!这个难理解一点
		$("#remarkId").val(id);

		//找到指定的存放备注信息的h5标签
		var noteContent=$("#e"+id).html();//这行操作一定要会！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！1
		//将h5中展现你出来的原始信息，赋予到修改操作的模态窗口的文本域中
		$("#noteContent").val(noteContent);

		//以上信息处理完毕后，将修改备注的模态窗口打开
		$("#editRemarkModal").modal("show")
	}
//删除备注的操作
	function deleteRemark(id) {  //上面使用这个方法传参的时候。字符串的拼接我真的看不懂！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！
		//课中讲的是因为是动态生成的元素所触发的方法的参数必须套在字符串当中
		//alert(id)
		if(confirm("确认删除该备注吗？")){
			$.ajax({
				url:"workbench/customer/deleteRemark.do",
				data:{   "id":id                              // 这里是你传递的数据
				},
				type:"post",
				dataType: "json",                                 //这里是你想要的数据类型
				success:function (data) {
					//data
					// { "success":true/false}
					if(data.success){


						//showRemarkList();
						//showRemarkList(); 这样写会导致越删除越多。因为他虽然删除了数据。
						// 但是不会清空之前已经读出来的,因为使用的是before方法
						//所以会不断增多.所以改进如下

						$("#"+id).remove();//首先在动态生成的语句中，为每个活动备注加上id。。这是一个小技巧！！！！！！！！！！！！！！！！！！！！！
						//注意这里$("#"+id)的特殊方式。表示的意思是根据每个活动备注的id
						//去找到对应div块。即活动备注。然后删除他即可
					}
					else {
						alert("删除备注失败");
					}
				}
			})

		}
	}
//展示所有交易
	function showTranList() {
		$.ajax({
			url:"workbench/customer/getTranListByCid.do",
			data:{"id":"${c.id}"
			},
			type:"get",
			dataType: "json",                                 //这里是你想要的数据类型
			success:function (data) {
				/*
				data[{交易1}{2}{3}]
				 */
				var  html="";
				$.each(data,function (i,n) {
					html += '<tr id="'+n.id+'">';
					html += '<td><a href="workbench/transaction/detail.do?id='+n.id+'" style="text-decoration: none;">'+n.customerId+'-'+n.name+'</a></td>';
					html += '<td>'+n.money+'</td>';
					html += '<td>'+n.stage+'</td>';
					html += '<td>'+json[n.stage]+'</td>';
					html += '<td>'+n.expectedDate+'</td>';
					html += '<td>'+n.type+'</td>';
					html += '<td><a href="#" onclick="deleteTran1(\''+n.id+'\')"  data-toggle="modal" data-target="#removeTransactionModal"  style="text-decoration: none;"><span class="glyphicon glyphicon-remove"></span>删除</a></td>';
					html += '</tr>';
				})
				$("#tranBody").html(html);
			}
		})


	}
//用来转换交易id的
	function deleteTran1(id) {
		//lert(id)
		$("#shanchujiaoyiId").val(id);

	}
//删除交易.
	function deleteTran(id) {

			$.ajax({
				url:"workbench/customer/deleteTran.do",
				data:{"id":id},          //因为这次是按照key=value&key=value  的形式传/!!!!!!!!!!！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！!!!1这里不要{}
				type:"post",     //删除操作，使用post
				dataType: "json",                                 //这里是你想要的数据类型
				success:function (data) {
					/*
                    data
                    {"success":true/false}
                     */
					if(data.success){
						//
						$("#"+id).remove();

					}else {
						alert("删除交易失败")
					}


				}
			})



	}

//展示联系人
	function showContactsList() {
		$.ajax({
			url:"workbench/customer/getContactsListByCid.do",
			data:{"id":"${c.id}"
			},
			type:"get",
			dataType: "json",                                 //这里是你想要的数据类型
			success:function (data) {
				/*
				data[{联系人1}{2}{3}]
				 */
				var html="";
				$.each(data,function (i,n) {
					html += '<tr id="'+n.id+'">';
					html += '<td><a href="contacts/detail.jsp" style="text-decoration: none;">'+n.fullname+'</a></td>';
					html += '<td>'+n.email+'</td>';
					html += '<td>'+n.mphone+'</td>';
					html += '<td><a href="#" onclick="deleteContacts1(\''+n.id+'\')" data-toggle="modal" data-target="#removeContactsModal" style="text-decoration: none;"><span class="glyphicon glyphicon-remove"></span>删除</a></td>';
					html += '</tr>';
				})
				$("#contactsBody").html(html);

			}
		})

	}
//用来转换联系人id的
	function deleteContacts1(id) {
		//alert(id)
		$("#shanchucontactsId").val(id)
	}
//删除联系人
	function deleteContacts(id) {
		$.ajax({
			url:"workbench/customer/deleteContacts.do",
			data:{"id":id
			},
			type:"get",
			dataType: "json",                                 //这里是你想要的数据类型
			success:function (data) {
				if(data.success){
					//
					$("#"+id).remove();

				}else {
					alert("删除交易活动失败")
				}
			}
		})

	}
//最上方的编辑按钮
	function bianji(id) {//这里面的方法使用的是从修改哪里拿过来的。只是稍微修改了一下
		//alert(id)
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
//最上面的删除按钮
	function shanchu(id) {
		if(confirm("确定要删除吗？")){
			var param="id="+id;
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
						var url=document.referrer;
						window.location.href=url;

					}else {
						alert("删除客户失败")
					}


				}
			})
		}
	}





</script>

</head>
<body>

	<!-- 删除联系人的模态窗口 -->
	<div class="modal fade" id="removeContactsModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 30%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">删除联系人</h4>
				</div>
				<div class="modal-body">
					<p>您确定要删除该联系人吗？</p>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
					<button type="button" onclick="deleteContacts($('#shanchucontactsId').val())" class="btn btn-danger" data-dismiss="modal">删除</button>
				</div>
				<input type="hidden" id="shanchucontactsId">
			</div>
		</div>
	</div>

    <!-- 删除交易的模态窗口 -->
    <div class="modal fade" id="removeTransactionModal" role="dialog">
        <div class="modal-dialog" role="document" style="width: 30%;">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">
                        <span aria-hidden="true">×</span>
                    </button>
                    <h4 class="modal-title">删除交易</h4>
                </div>
                <div class="modal-body">
                    <p>您确定要删除该交易吗？</p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
                    <button type="button" class="btn btn-danger" onclick="deleteTran($('#shanchujiaoyiId').val())" data-dismiss="modal">删除</button>
                </div>
				<input type="hidden" id="shanchujiaoyiId">
            </div>
        </div>
    </div>
	
	<!-- 创建联系人的模态窗口 -->
	<div class="modal fade" id="createContactsModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" onclick="$('#createContactsModal').modal('hide');">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel1">创建联系人</h4>
				</div>
				<div class="modal-body">
					<form action="workbench/customer/saveContacts.do" id="tranForm" class="form-horizontal" role="form">
					
						<div class="form-group">
							<label for="create-owner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-owner" name="owner">

								</select>
							</div>
							<label for="create-source" class="col-sm-2 control-label">来源</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-source" name="source">
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
								<input type="text" class="form-control" id="create-fullname" name="fullname">
							</div>
							<label for="create-appellation" class="col-sm-2 control-label">称呼</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-appellation" name="appellation">
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
								<input type="text" class="form-control" id="create-job" name="job">
							</div>
							<label for="create-mphone" class="col-sm-2 control-label">手机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-mphone" name="mphone">
							</div>
						</div>
						
						<div class="form-group" style="position: relative;">
							<label for="create-email" class="col-sm-2 control-label">邮箱</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-email" name="email">
							</div>
							<label for="create-birth" class="col-sm-2 control-label">生日</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-birth" name="birth">
							</div>
						</div>
						
						<div class="form-group" style="position: relative;">
							<label for="create-customerName" class="col-sm-2 control-label">客户名称</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control"  name="customerName" id="create-customerName" placeholder="支持自动补全，输入客户不存在则新建">
							</div>
						</div>
						
						<div class="form-group" style="position: relative;">
							<label for="create-description" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="create-description" name="description"></textarea>
							</div>
						</div>
						
						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative;"></div>

                        <div style="position: relative;top: 15px;">
                            <div class="form-group">
                                <label for="create-contactSummary" class="col-sm-2 control-label">联系纪要</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="3" id="create-contactSummary" name="contactSummary"></textarea>
                                </div>
                            </div>
                            <div class="form-group">
                                <label for="create-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
                                <div class="col-sm-10" style="width: 300px;">
                                    <input type="text" class="form-control time" id="create-nextContactTime" name="nextContactTime">
                                </div>
                            </div>
                        </div>

                        <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

                        <div style="position: relative;top: 20px;">
                            <div class="form-group">
                                <label for="create-address1" class="col-sm-2 control-label">详细地址</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="1" id="create-address1" name="address"></textarea>
                                </div>
                            </div>
                        </div>
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button"  id="saveContacts" class="btn btn-primary" data-dismiss="modal">保存</button>
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
						<input type="hidden" id="edit-id">

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
                                <input type="text" class="form-control" id="edit-website" value="http://www.bjpowernode.com">
                            </div>
                            <label for="edit-phone" class="col-sm-2 control-label">公司座机</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-phone" value="010-84846003">
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
                                    <input type="text" class="form-control" id="edit-nextContactTime">
                                </div>
                            </div>
                        </div>

                        <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

                        <div style="position: relative;top: 20px;">
                            <div class="form-group">
                                <label for="edit-address" class="col-sm-2 control-label">详细地址</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="1" id="edit-address">北京大兴大族企业湾</textarea>
                                </div>
                            </div>
                        </div>
                    </form>

                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                    <button type="button" class="btn btn-primary" id="updateBtn" data-dismiss="modal">更新</button>
                </div>
            </div>
        </div>
    </div>

	<!-- 返回按钮 -->
	<div style="position: relative; top: 35px; left: 10px;">
		<a href="javascript:void(0);" onclick="window.history.back();"><span class="glyphicon glyphicon-arrow-left" style="font-size: 20px; color: #DDDDDD"></span></a>
	</div>
	
	<!-- 大标题 -->
	<div style="position: relative; left: 40px; top: -30px;">
		<div class="page-header">
			<h3>${c.name} <small><a href="http://${c.website}" target="_blank">${c.website}</a></small></h3>
		</div>
		<div style="position: relative; height: 50px; width: 500px;  top: -72px; left: 700px;">
			<button type="button" class="btn btn-default" onclick="bianji('${c.id}')" data-toggle="modal" data-target="#editCustomerModal"><span class="glyphicon glyphicon-edit"></span> 编辑</button>
			<button type="button" class="btn btn-danger" onclick="shanchu('${c.id}')"><span class="glyphicon glyphicon-minus"></span> 删除</button>
		</div>
	</div>
	
	<!-- 详细信息 -->
	<div style="position: relative; top: -70px;">
		<div style="position: relative; left: 40px; height: 30px;">
			<div style="width: 300px; color: gray;">所有者</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>&nbsp;${c.owner}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">名称</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>&nbsp;${c.name}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 10px;">
			<div style="width: 300px; color: gray;">公司网站</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>&nbsp;${c.website}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">公司座机</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>&nbsp;${c.phone}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 20px;">
			<div style="width: 300px; color: gray;">创建者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>&nbsp;${c.createBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${c.createTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 30px;">
			<div style="width: 300px; color: gray;">修改者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>&nbsp;${c.editBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${c.editTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
        <div style="position: relative; left: 40px; height: 30px; top: 40px;">
            <div style="width: 300px; color: gray;">联系纪要</div>
            <div style="width: 630px;position: relative; left: 200px; top: -20px;">
                <b>
					&nbsp;${c.contactSummary}
                </b>
            </div>
            <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
        </div>
        <div style="position: relative; left: 40px; height: 30px; top: 50px;">
            <div style="width: 300px; color: gray;">下次联系时间</div>
            <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>&nbsp;${c.nextContactTime}</b></div>
            <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px; "></div>
        </div>
		<div style="position: relative; left: 40px; height: 30px; top: 60px;">
			<div style="width: 300px; color: gray;">描述</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>
					&nbsp;${c.description}
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
        <div style="position: relative; left: 40px; height: 30px; top: 70px;">
            <div style="width: 300px; color: gray;">详细地址</div>
            <div style="width: 630px;position: relative; left: 200px; top: -20px;">
                <b>
					&nbsp;${c.address}
                </b>
            </div>
            <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
        </div>
	</div>
	
	<!-- 备注 -->
	<div style="position: relative; top: 10px; left: 40px;" id="remarkBody">
		<div class="page-header">
			<h4>备注</h4>
		</div>

		<!-- 修改备注的模态窗口 -->
		<div class="modal fade" id="editRemarkModal" role="dialog">
			<%-- 备注的id --%>
			<input type="hidden" id="remarkId">

			<div class="modal-dialog" role="document" style="width: 40%;">
				<div class="modal-content">
					<div class="modal-header">
						<button type="button" class="close" data-dismiss="modal">
							<span aria-hidden="true">×</span>
						</button>
						<h4 class="modal-title" id="myModalLabel0">修改备注</h4>
					</div>
					<div class="modal-body">
						<form class="form-horizontal" role="form">
							<div class="form-group">
								<label for="noteContent" class="col-sm-2 control-label">内容</label>
								<div class="col-sm-10" style="width: 81%;">
									<textarea class="form-control" rows="3" id="noteContent"></textarea>
								</div>
							</div>
						</form>
					</div>
					<div class="modal-footer">
						<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
						<button type="button" class="btn btn-primary" id="updateRemarkBtn">更新</button>
					</div>
				</div>
			</div>
		</div>

		
		<div id="remarkDiv" style="background-color: #E6E6E6; width: 870px; height: 90px;">
			<form role="form" style="position: relative;top: 10px; left: 10px;">
				<textarea id="remark" class="form-control" style="width: 850px; resize : none;" rows="2"  placeholder="添加备注..."></textarea>
				<p id="cancelAndSaveBtn" style="position: relative;left: 737px; top: 10px; display: none;">
					<button id="cancelBtn" type="button" class="btn btn-default">取消</button>
					<button type="button" class="btn btn-primary" id="remarkBtn">保存</button>
				</p>
			</form>
		</div>
	</div>
	
	<!-- 交易 -->
	<div>
		<div style="position: relative; top: 20px; left: 40px;">
			<div class="page-header">
				<h4>交易</h4>
			</div>
			<div style="position: relative;top: 0px;">
				<table id="activityTable2" class="table table-hover" style="width: 900px;">
					<thead>
						<tr style="color: #B3B3B3;">
							<td>名称</td>
							<td>金额</td>
							<td>阶段</td>
							<td>可能性</td>
							<td>预计成交日期</td>
							<td>类型</td>
							<td></td>
						</tr>
					</thead>
					<tbody id="tranBody">
<%--						<tr>--%>
<%--							<td><a href="transaction/detail.jsp" style="text-decoration: none;">动力节点-交易01</a></td>--%>
<%--							<td>5,000</td>--%>
<%--							<td>谈判/复审</td>--%>
<%--							<td>90</td>--%>
<%--							<td>2017-02-07</td>--%>
<%--							<td>新业务</td>--%>
<%--							<td><a href="javascript:void(0);" data-toggle="modal" data-target="#removeTransactionModal" style="text-decoration: none;"><span class="glyphicon glyphicon-remove"></span>删除</a></td>--%>
<%--						</tr>--%>
					</tbody>
				</table>
			</div>
			
			<div >
				<a href="workbench/transaction/add.do" style="text-decoration: none;"><span class="glyphicon glyphicon-plus"></span>新建交易</a>
			</div>
		</div>
	</div>
	
	<!-- 联系人 -->
	<div>
		<div style="position: relative; top: 20px; left: 40px;">
			<div class="page-header">
				<h4>联系人</h4>
			</div>
			<div style="position: relative;top: 0px;">
				<table id="activityTable" class="table table-hover" style="width: 900px;">
					<thead>
						<tr style="color: #B3B3B3;">
							<td>名称</td>
							<td>邮箱</td>
							<td>手机</td>
							<td></td>
						</tr>
					</thead>
					<tbody id="contactsBody">

					</tbody>
				</table>
			</div>
			
			<div>
				<a href="javascript:void(0);" id="newContacts" data-toggle="modal" data-target="#createContactsModal" style="text-decoration: none;"><span class="glyphicon glyphicon-plus"></span>新建联系人</a>
			</div>
		</div>
	</div>
	
	<div style="height: 200px;"></div>
</body>
</html>