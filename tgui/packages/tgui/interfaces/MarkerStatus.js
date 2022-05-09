import { classes } from 'common/react';
import { createSearch } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import { Flex, Divider, Collapsible, Icon, Button, Input, NumberInput, Fragment, Table } from '../components';
import { Window } from '../layouts';

const redFont = {
  color: "red",
};

/**
 * Creates a filter function based on the search key (passed to the search bar),
 * the categories selected to be searched through, and the max health filter
 */
const getFilter = data => {
  const {
    searchKey, searchFilters, maxHealth,
  } = data;
  const textSearch = createSearch(searchKey);

  return entry => {
    if (entry.health > maxHealth) {
      return false;
    }

    let hasFilter = false;
    for (let filter in searchFilters) {
      if (searchFilters[filter]) {
        hasFilter = true;
        if (textSearch(entry[filter])) {
          return true;
        }
      }
    }

    return hasFilter ? false : true;
  };
};

/**
 * Filters the list of necros and returns a set of rows that will be used in the
 * necro list table
 */
const filterNecros = data => {
  const {
    searchKey, searchFilters,
    maxHealth, necro_keys,
    necro_vitals, necro_info,
  } = data;
  const necro_entries = [];

  necro_keys.map((key, i) => {
    const nicknumber = key.nicknumber.toString();
    let entry = {
      nicknumber: nicknumber,
      name: necro_info[nicknumber].name,
      strain: necro_info[nicknumber].strain,
      location: necro_vitals[nicknumber].area,
      health: necro_vitals[nicknumber].health,
      ref: necro_info[nicknumber].ref,
      is_ssd: necro_vitals[nicknumber].is_ssd,
      is_leader: key.is_leader,
      is_marker: key.is_marker,
    };
    necro_entries.push(entry);
  });

  const filter_params = {
    searchKey: searchKey,
    searchFilters: searchFilters,
    maxHealth: maxHealth,
  };
  const filtered = necro_entries.filter(getFilter(filter_params));

  return filtered;
};

const StatusIcon = (props, context) => {
  const { entry } = props;
  const { is_ssd, is_leader, is_queen } = entry;

  if (is_ssd) {
    return <div unselectable="on" className="ssdIcon" />;
  } else if (is_leader || is_queen) {
    return (
      <div unselectable="on" className="leaderIcon">
        <Icon name="star" ml={0.2} />
      </div>
    );
  }
};

export const MarkerStatus = (props, context) => {
  const { data } = useBackend(context);
  const { marker_name } = data;

  return (
    <Window
      title={marker_name + " Status"}
      theme="marker_status"
      resizable
      width={600}
      height={680}
    >
      <Window.Content scrollable>
        <NecroCollapsible
          title="General Marker Information"
        >
          <GeneralInformation />
        </NecroCollapsible>
        <Divider />
        <NecroCollapsible
          title="Marker Counts"
        >
          <NecroCounts />
        </NecroCollapsible>
        <Divider />
        <NecroCollapsible
          title="Marker Necromorph List"
        >
          <NecroList />
        </NecroCollapsible>
      </Window.Content>
    </Window>
  );
};

const NecroCollapsible = (props, context) => {
  const { data } = useBackend(context);
  const { title, children } = props;
  const { marker_color } = data;

  return (
    <Collapsible
      title={title}
      backgroundColor={!!marker_color && marker_color}
      color={!marker_color && "necro"}
      open
    >
      {children}
    </Collapsible>
  );
};

const GeneralInformation = (props, context) => {
  const { data } = useBackend(context);
  const {
    marker_location,
    total_necros,
  } = data;

  return (
    <Flex
      direction="column"
      align="center"
    >
      <Flex.Item
        textAlign="center"
      >
        <h3 className="whiteTitle">The Marker is in:</h3>
        <h1 className="whiteTitle">{marker_location}</h1>
      </Flex.Item>
      <Flex.Item
        mt={1}
      >
        <i>Total necros: {total_necros}</i>
      </Flex.Item>
    </Flex>
  );
};

const NecroCounts = (props, context) => {
  const { data } = useBackend(context);
  const { necro_counts, marker_color } = data;

  return (
    <Flex
      direction="column-reverse"
    >
      {necro_counts.map((counts, tier) => {
        return (
          <Flex.Item
            key={tier}
            mb={tier !== 0 ? 2 : 0}
          >
            <Flex
              direction="column"
            >
              <Flex.Item>
                <center>
                  <h1 className="whiteTitle">Tier {tier+1}</h1>
                </center>
              </Flex.Item>
              <Flex.Item>
                <center>
                  <Table className="necroCountTable" collapsing>
                    <Table.Row header>
                      {Object.keys(counts).map((caste, i) => (
                        <Table.Cell
                          key={i}
                          className="underlineCell"
                          width={7}
                        >
                          {caste === 'Bloody Larva' ? 'Larva' : caste}
                        </Table.Cell>
                      ))}
                    </Table.Row>
                    <Table.Row className="necroCountRow">
                      {Object.keys(counts).map((caste, i) => (
                        <Table.Cell key={i}
                          className="necroCountCell"
                          backgroundColor={!!marker_color && marker_color}
                          textAlign="center"
                          width={7}
                        >
                          {counts[caste]}
                        </Table.Cell>
                      ))}
                    </Table.Row>
                  </Table>
                </center>
              </Flex.Item>
            </Flex>
          </Flex.Item>
        ); })}
    </Flex>
  );
};

const NecroList = (props, context) => {
  const { act, data } = useBackend(context);
  const [searchKey, setSearchKey] = useLocalState(context, 'searchKey', '');
  const [searchFilters, setSearchFilters] = useLocalState(context, 'searchFilters', { name: true, strain: true, location: true });
  const [maxHealth, setMaxHealth] = useLocalState(context, 'maxHealth', 100);
  const {
    necro_keys, necro_vitals,
    necro_info, user_ref,
    marker_color,
  } = data;
  const necro_entries = filterNecros({
    searchKey: searchKey,
    searchFilters: searchFilters,
    maxHealth: maxHealth,
    necro_keys: necro_keys,
    necro_vitals: necro_vitals,
    necro_info: necro_info,
  });

  return (
    <Flex
      direction="column"
    >
      <Flex.Item mb={1}>
        <Flex
          align="baseline"
        >
          <Flex.Item width="100px">
            Search Filters:
          </Flex.Item>
          <Flex.Item>
            <Button.Checkbox
              inline
              content="Name"
              checked={searchFilters.name}
              backgroundColor={searchFilters.name && marker_color}
              onClick={() => setSearchFilters({
                ...searchFilters,
                name: !searchFilters.name,
              })}
            />
            <Button.Checkbox
              inline
              content="Strain"
              checked={searchFilters.strain}
              backgroundColor={searchFilters.strain && marker_color}
              onClick={() => setSearchFilters({
                ...searchFilters,
                strain: !searchFilters.strain,
              })}
            />
            <Button.Checkbox
              inline
              content="Location"
              checked={searchFilters.location}
              backgroundColor={searchFilters.location && marker_color}
              onClick={() => setSearchFilters({
                ...searchFilters,
                location: !searchFilters.location,
              })}
            />
          </Flex.Item>
        </Flex>
      </Flex.Item>
      <Flex.Item mb={1}>
        <Flex
          align="baseline"
        >
          <Flex.Item width="100px">
            Max Health:
          </Flex.Item>
          <Flex.Item>
            <NumberInput
              animated
              width="40px"
              step={1}
              stepPixelSize={5}
              value={maxHealth}
              minValue={0}
              maxValue={100}
              onChange={(_, value) => setMaxHealth(value)}
            />
          </Flex.Item>
        </Flex>
      </Flex.Item>
      <Flex.Item mb={2}>
        <Input
          fluid={1}
          placeholder="Search..."
          onInput={(_, value) => setSearchKey(value)}
        />
      </Flex.Item>

      <Table className="necro_list">
        <Table.Row header className="necroListRow">
          <Table.Cell width="5%" className="noPadCell" />
          <Table.Cell>Name</Table.Cell>
          <Table.Cell width="15%">Strain</Table.Cell>
          <Table.Cell>Location</Table.Cell>
          <Table.Cell width="75px">Health</Table.Cell>
          <Table.Cell width="100px" />
        </Table.Row>

        {necro_entries.map((entry, i) => (
          <Table.Row
            key={i}
            className={classes([
              entry.is_ssd ? "ssdRow" : "",
              "necroListRow",
            ])}
          >
            {/*
              Leader/SSD icon
              You might think using an image for rounded corners is stupid,
              but I shit you not, BYOND's version of IE doesn't support
              border-radius
            */}
            <Table.Cell className="noPadCell">
              <StatusIcon entry={entry} />
            </Table.Cell>
            <Table.Cell>{entry.name}</Table.Cell>
            <Table.Cell>{entry.strain}</Table.Cell>
            <Table.Cell>{entry.location}</Table.Cell>
            <Table.Cell>
              {entry.health < 30
                ? <b style={redFont}>{entry.health}%</b>
                : <Fragment>{entry.health}%</Fragment>}
            </Table.Cell>
            <Table.Cell className="noPadCell" textAlign="center">
              {entry.ref !== user_ref && (
                <Flex
                  unselectable="on"
                  wrap="wrap"
                  className="actionButton"
                  align="center"
                  justify="space-around"
                  inline
                >
                  <Flex.Item>
                    <Button
                      content="Watch"
                      color="necro"
                      onClick={
                        () => act("watch", {
                          target_ref: entry.ref,
                        })
                      }
                    />
                  </Flex.Item>
                  <MarkerButtons target_ref={entry.ref} />
                </Flex>
              )}
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Flex>
  );
};

const MarkerButtons = (props, context) => {
  const { act, data } = useBackend(context);
  const { target_ref } = props;

  return (
    <Fragment>
      <Flex.Item>
        <Button
          content="Rebuild"
          color="green"
          onClick={
            () => act("rebuild", {
              target_ref: target_ref,
            })
          }
        />
      </Flex.Item>
      <Flex.Item>
        <Button
          content="Reconstruct"
          color="blue"
          onClick={
            () => act("reconstruct", {
              target_ref: target_ref,
            })
          }
        />
      </Flex.Item>
    </Fragment>
  );
};
