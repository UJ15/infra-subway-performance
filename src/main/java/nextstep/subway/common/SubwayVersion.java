package nextstep.subway.common;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import javax.annotation.PostConstruct;
import org.springframework.stereotype.Component;

@Component
public class SubwayVersion {
    private static final String DEFAULT_DATE_TIME_FORMAT = "yyyyMMddHHmmss";

    private String version;

    @PostConstruct
    public void init() {
        version = nowVersion();
    }

    public String getVersion() {
        return version;
    }

    private static String nowVersion() {
        return LocalDateTime.now().format(DateTimeFormatter.ofPattern(DEFAULT_DATE_TIME_FORMAT));
    }
}