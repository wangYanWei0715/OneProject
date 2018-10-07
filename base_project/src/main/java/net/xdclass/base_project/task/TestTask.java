package net.xdclass.base_project.task;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.util.Date;

/**
 * @描述: 测试定时任务
 * @参数: base_project
 * @创建人: wyw
 * @时间: 2018-10-02 11:28
 **/
@Component
public class TestTask {

    private  Long  aaa = 200L;

    //@Scheduled(fixedRate = 2000)
    @Scheduled(cron = "*/10 * * * * *")
    public void  tesy1(){
        System.out.println("当前时间"+ new Date());
    }
}
