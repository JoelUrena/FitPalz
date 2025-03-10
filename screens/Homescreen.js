import React, { useState } from 'react';
import { 
  View, Text, StyleSheet, Image, SafeAreaView, TouchableOpacity, ScrollView, LayoutAnimation, UIManager, Platform 
} from 'react-native';

// Enable  on Android (in case we need to implement android later)
if (Platform.OS === 'android' && UIManager.setLayoutAnimationEnabledExperimental) {
  UIManager.setLayoutAnimationEnabledExperimental(true);
}

export default function HomeScreen() {
  const [expandedStat, setExpandedStat] = useState(null);

  const handleToggle = (stat) => {
    LayoutAnimation.configureNext(LayoutAnimation.Presets.easeInEaseOut);
    setExpandedStat(expandedStat === stat ? null : stat);
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.contentWrapper}>
        {/* logo at the Top */}
        <Image source={require('../assets/logo.png')} style={styles.logo} />

        {/* welcome Message */}
        <Text style={styles.welcomeText}>Welcome Back!</Text>

        {/* scrollable stats  */}
        <ScrollView contentContainerStyle={styles.scrollContainer} showsVerticalScrollIndicator={false}>
          {statsData.map((stat, index) => (
            <TouchableOpacity
              key={index}
              style={[styles.statButton, expandedStat === stat.label ? styles.statButtonActive : null]}
              onPress={() => handleToggle(stat.label)}
              activeOpacity={0.8}
            >
              <View style={styles.statContent}>
                {/* circular Icon */}
                <View style={styles.statIcon}>
                  <Text style={styles.iconText}>{stat.icon}</Text>
                </View>

                {/* stat label and value */}
                <Text style={styles.statText}>{stat.label}: {stat.value}</Text>
              </View>

              {/* toggle effect */}
              {expandedStat === stat.label && (
                <View style={styles.expandedContent}>
                  <Text style={styles.expandedText}>{stat.details}</Text>
                </View>
              )}
            </TouchableOpacity>
          ))}
        </ScrollView>
      </View>
    </SafeAreaView>
  );
}

const statsData = [
  { label: 'Calories Burned', value: '1200', icon: '🔥', details: 'You burned 1200 kcal today! Keep up the good work!' },
  { label: 'Steps Taken', value: '10,500', icon: '🏃‍♂️', details: 'You’ve taken 10,500 steps! That’s an amazing effort!' },
  { label: 'Distance', value: '7.2 miles', icon: '📏', details: 'You covered 7.2 miles today. Stay active!' },
  { label: 'Challenges', value: '30% complete', icon: '🏆', details: 'You’ve completed 30% of your challenges. Keep pushing forward!' },
  { label: 'Sleep', value: '40 hours', icon: '🌙', details: 'You’ve accumulated 40 hours of sleep this week. Aim for consistency!' },
];

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#000',
    paddingTop: 50, // moves everything down slightly
  },
  contentWrapper: {
    flex: 1, // makes sure content takes up the screen
    alignItems: 'center',
    justifyContent: 'flex-start', // content starts from the top
  },
  logo: {
    width: '100%',
    height: 200,
    resizeMode: 'contain', //image scales properly
    marginBottom: 20, //adds space between logo and welcome text
  },
  welcomeText: {
    color: '#fff',
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 20, // adds spacing before the stats
  },
  scrollContainer: {
    flexGrow: 1, //content to expand properly
    alignItems: 'center',
    paddingBottom: 40, // extra space for scrolling
  },
  statButton: {
    backgroundColor: '#222',
    padding: 15,
    borderRadius: 10,
    width: '90%',
    marginVertical: 10,
  },
  statButtonActive: {
    backgroundColor: '#8A2BE2',
  },
  statContent: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  statIcon: {
    width: 50,
    height: 50,
    borderRadius: 25,
    backgroundColor: '#444',
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 15,
  },
  iconText: {
    fontSize: 24,
  },
  statText: {
    color: '#fff',
    fontSize: 18,
    fontWeight: 'bold',
    flex: 1,
  },
  expandedContent: {
    marginTop: 10,
    padding: 10,
    backgroundColor: '#333',
    borderRadius: 8,
  },
  expandedText: {
    color: '#fff',
    fontSize: 14,
    textAlign: 'center',
  },
});





















