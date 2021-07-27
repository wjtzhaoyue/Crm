package com.bjpowernode.crm.settings.service;


import com.bjpowernode.crm.settings.domain.DicValue;

import java.util.List;
import java.util.Map;

//这里只写了一个DicService.不用单独给dicvaule'和dictype分别写一个接口
//记住：其实service几乎就是dao'

public interface DicService {
    Map<String, List<DicValue>> getAll();
}
