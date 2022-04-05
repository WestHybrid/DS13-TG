import { useBackend } from '../backend';
import { Stack, Tabs } from '../components';
import { Window } from '../layouts';

export const BioprotesticConsole = (props, context) => {
  const { data, act } = useBackend(context);
  const {
    selected_tank,
    organs,
    tanks,
  } = data;
  return (
    <Window
      width={550}
      height={420}>
      <Window.Content>
        <Stack fill>
          <Stack.Item grow={0.3}>
            <Tabs vertical>
              {tanks.map((tank, index) => (
                <Tabs.Tab
                  key={tank.id}
                  selected={selected_tank === tank.id}
                  onClick={() => act('select_tank', { id: tank.id })}>
                  {tank.name}
                </Tabs.Tab>
              ))}
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>t</Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
