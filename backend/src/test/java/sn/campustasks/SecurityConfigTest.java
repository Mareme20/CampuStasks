package sn.campustasks;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
class SecurityConfigTest {

  @Autowired
  private MockMvc mockMvc;

  @Test
  void protectedEndpointsRequireAuthentication() throws Exception {
    mockMvc.perform(get("/api/v1/dashboard"))
        .andExpect(status().isUnauthorized());
  }

  @Test
  void healthEndpointsRemainPublic() throws Exception {
    mockMvc.perform(get("/health"))
        .andExpect(status().isOk());

    mockMvc.perform(get("/api/v1/health"))
        .andExpect(status().isOk());
  }
}
