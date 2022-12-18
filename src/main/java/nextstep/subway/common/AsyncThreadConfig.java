package nextstep.subway.common;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;

import java.util.concurrent.Executor;

@Configuration
@EnableAsync
public class AsyncThreadConfig {

    @Bean
    public Executor asyncThreadTaskExecutor() {
        ThreadPoolTaskExecutor exexcutor = new ThreadPoolTaskExecutor();
        exexcutor.setCorePoolSize(3);
        exexcutor.setMaxPoolSize(3);
        exexcutor.setQueueCapacity(100);
        exexcutor.setThreadNamePrefix("subway-async-");
        return exexcutor;
    }
}
