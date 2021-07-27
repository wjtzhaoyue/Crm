package com.bjpowernode.crm.settings.service.Impl;

import com.bjpowernode.crm.settings.dao.DicTypeDao;
import com.bjpowernode.crm.settings.dao.DicValueDao;
import com.bjpowernode.crm.settings.domain.DicType;
import com.bjpowernode.crm.settings.domain.DicValue;
import com.bjpowernode.crm.settings.service.DicService;
import com.bjpowernode.crm.utils.SqlSessionUtil;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class DicServiceImpl implements DicService {
    private DicTypeDao dicTypeDao= SqlSessionUtil.getSqlSession().getMapper(DicTypeDao.class);
    private DicValueDao dicValueDao= SqlSessionUtil.getSqlSession().getMapper(DicValueDao.class);

    public Map<String, List<DicValue>> getAll() {
        Map<String, List<DicValue>> map=new HashMap<String, List<DicValue>>();
        //这里为什么要 List<DicType>是这种类型的！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！！

        List<DicType> dtList=dicTypeDao.getTypeList();

        //
        for(DicType dt:dtList){
            String code=dt.getCode();

            List<DicValue> dvList=dicValueDao.getListByCode(code);

            map.put(code+"List",dvList);

        }


        return map;
    }
}
